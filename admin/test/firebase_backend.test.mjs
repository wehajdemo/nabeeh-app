// Exercises createFirebaseBackend() against a small in-memory fake of the
// Firebase web SDK (the real one needs a project / emulator).
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { ConflictError, createFirebaseBackend } from '../js/data.js';
import { DEFAULT_PROGRAMS } from '../js/schedule.js';

const SERVER_TIME = Symbol('serverTimestamp');

function fakeSdk({ docs = {}, adminUids = [], now = new Date('2026-10-22T12:00:00Z') } = {}) {
  const store = new Map(Object.entries(docs));
  const calls = { transactions: 0, signIn: [], signOut: 0 };
  let authListener;
  const stamp = (date) => ({ toDate: () => date });
  const snapshot = (path) => ({
    exists: () => store.has(path),
    data: () => store.get(path),
  });
  const commit = (path, data) => {
    store.set(path, { ...data, updatedAt: data.updatedAt === SERVER_TIME ? stamp(now) : data.updatedAt });
  };

  const sdk = {
    app: { initializeApp: (config) => ({ config }) },
    auth: {
      getAuth: () => ({}),
      onAuthStateChanged: (_auth, cb) => { authListener = cb; return () => { authListener = null; }; },
      signInWithEmailAndPassword: async (_auth, email, password) => {
        calls.signIn.push([email, password]);
        if (password === 'bad') throw Object.assign(new Error('x'), { code: 'auth/invalid-credential' });
      },
      signOut: async () => { calls.signOut++; },
    },
    fs: {
      getFirestore: () => ({}),
      doc: (_db, ...segments) => ({ path: segments.join('/') }),
      serverTimestamp: () => SERVER_TIME,
      getDocFromServer: async (ref) => {
        if (ref.path.startsWith('admins/') && !adminUids.includes(ref.path.slice(7))) {
          return { exists: () => false };
        }
        if (ref.path.startsWith('admins/')) return { exists: () => true, data: () => ({}) };
        return snapshot(ref.path);
      },
      runTransaction: async (_db, fn) => {
        calls.transactions++;
        const writes = [];
        const result = await fn({
          get: async (ref) => snapshot(ref.path),
          set: (ref, data) => writes.push([ref.path, data]),
        });
        for (const [path, data] of writes) commit(path, data);
        return result;
      },
    },
  };
  return { sdk, store, calls, emitAuth: (user) => authListener?.(user) };
}

const PATH = 'config/payout_schedule';
const doc = (updatedAt, by = 'old@x.com') => ({ programs: DEFAULT_PROGRAMS, updatedAt: { toDate: () => updatedAt }, updatedBy: by });

test('load: nothing published yet', async () => {
  const { sdk } = fakeSdk();
  const backend = await createFirebaseBackend({}, sdk);
  assert.deepEqual(await backend.load(), { exists: false, programs: [], updatedAt: null, updatedBy: null });
});

test('load: reads programs, publish time and author', async () => {
  const at = new Date('2026-10-20T08:00:00Z');
  const { sdk } = fakeSdk({ docs: { [PATH]: doc(at) } });
  const backend = await createFirebaseBackend({}, sdk);
  const data = await backend.load();
  assert.equal(data.exists, true);
  assert.equal(data.programs.length, 5);
  assert.equal(data.updatedAt.getTime(), at.getTime());
  assert.equal(data.updatedBy, 'old@x.com');
});

test('load: drops invalid programs from the stored document', async () => {
  const bad = { ...DEFAULT_PROGRAMS[0], id: 'bad', dayOfMonth: 99 };
  const { sdk } = fakeSdk({ docs: { [PATH]: { ...doc(new Date()), programs: [bad, DEFAULT_PROGRAMS[1]] } } });
  const data = await (await createFirebaseBackend({}, sdk)).load();
  assert.deepEqual(data.programs.map((p) => p.id), ['citizen-account']);
});

test('isAdmin: true only for uids present in admins/', async () => {
  const { sdk } = fakeSdk({ adminUids: ['u1'] });
  const backend = await createFirebaseBackend({}, sdk);
  assert.equal(await backend.isAdmin({ uid: 'u1' }), true);
  assert.equal(await backend.isAdmin({ uid: 'u2' }), false);
});

test('isAdmin: a failed lookup counts as not admin', async () => {
  const { sdk } = fakeSdk();
  sdk.fs.getDocFromServer = async () => { throw new Error('offline'); };
  assert.equal(await (await createFirebaseBackend({}, sdk)).isAdmin({ uid: 'u1' }), false);
});

test('save: first publish writes programs, author and server timestamp', async () => {
  const { sdk, store } = fakeSdk();
  const backend = await createFirebaseBackend({}, sdk);
  const { updatedAt } = await backend.save(DEFAULT_PROGRAMS, { uid: 'u1', email: 'me@x.com' }, null);
  const written = store.get(PATH);
  assert.equal(written.programs.length, 5);
  assert.equal(written.updatedBy, 'me@x.com');
  assert.deepEqual(Object.keys(written).sort(), ['programs', 'updatedAt', 'updatedBy']); // what the rules allow
  assert.equal(updatedAt.toISOString(), '2026-10-22T12:00:00.000Z');
});

test('save: succeeds when the server still has the version we loaded', async () => {
  const at = new Date('2026-10-20T08:00:00Z');
  const { sdk, store } = fakeSdk({ docs: { [PATH]: doc(at) } });
  const backend = await createFirebaseBackend({}, sdk);
  await backend.save(DEFAULT_PROGRAMS.slice(0, 2), { email: 'me@x.com' }, at);
  assert.equal(store.get(PATH).programs.length, 2);
});

test('save: refuses to overwrite a newer publish (conflict)', async () => {
  const loaded = new Date('2026-10-20T08:00:00Z');
  const newer = new Date('2026-10-21T09:00:00Z');
  const { sdk, store } = fakeSdk({ docs: { [PATH]: doc(newer, 'other@x.com') } });
  const backend = await createFirebaseBackend({}, sdk);
  await assert.rejects(backend.save([], { email: 'me@x.com' }, loaded), ConflictError);
  assert.equal(store.get(PATH).updatedBy, 'other@x.com'); // untouched
});

test('save: conflict when someone published first and we thought nothing existed', async () => {
  const { sdk } = fakeSdk({ docs: { [PATH]: doc(new Date()) } });
  const backend = await createFirebaseBackend({}, sdk);
  await assert.rejects(backend.save(DEFAULT_PROGRAMS, { email: 'me@x.com' }, null), ConflictError);
});

test('auth: forwards state changes as {uid, email} and signs in / out', async () => {
  const { sdk, calls, emitAuth } = fakeSdk();
  const backend = await createFirebaseBackend({}, sdk);
  const seen = [];
  backend.onAuthChange((u) => seen.push(u));
  emitAuth({ uid: 'u1', email: 'a@b.c', extra: 1 });
  emitAuth(null);
  assert.deepEqual(seen, [{ uid: 'u1', email: 'a@b.c' }, null]);

  await backend.signIn('a@b.c', 'pw');
  assert.deepEqual(calls.signIn, [['a@b.c', 'pw']]);
  await assert.rejects(backend.signIn('a@b.c', 'bad'), { code: 'auth/invalid-credential' });
  await backend.signOut();
  assert.equal(calls.signOut, 1);
});
