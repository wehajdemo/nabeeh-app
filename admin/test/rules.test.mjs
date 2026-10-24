// Security-rules tests. They need the Firestore emulator, so they are skipped
// unless FIRESTORE_EMULATOR_HOST is set. Run with:
//   npm install && npm run test:rules
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';

const emulator = process.env.FIRESTORE_EMULATOR_HOST;

describe('firestore.rules', { skip: emulator ? false : 'Firestore emulator not running' }, () => {
  let env;
  let T; // @firebase/rules-unit-testing
  let F; // firebase/firestore

  const program = (over = {}) => ({
    id: 'p1', kind: 'other', category: 'government', title: 'x', provider: '',
    certainty: 'confirmed', dayOfMonth: 5, windowEndDay: null, note: '', windowNote: '', active: true, ...over,
  });
  const validDoc = (over = {}) => ({
    programs: [program()], updatedAt: F.serverTimestamp(), updatedBy: 'admin@x.com', ...over,
  });

  before(async () => {
    T = await import('@firebase/rules-unit-testing');
    F = await import('firebase/firestore');
    const [host, port] = emulator.split(':');
    env = await T.initializeTestEnvironment({
      projectId: 'demo-rateby',
      firestore: { host, port: Number(port), rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
    });
  });
  after(async () => { await env?.cleanup(); });
  beforeEach(async () => {
    await env.clearFirestore();
    await env.withSecurityRulesDisabled(async (ctx) => {
      await F.setDoc(F.doc(ctx.firestore(), 'admins/admin1'), { role: 'admin' });
      await F.setDoc(F.doc(ctx.firestore(), 'config/payout_schedule'), { programs: [program()], updatedAt: new Date(), updatedBy: 'seed' });
    });
  });

  const dbOf = (uid) => (uid ? env.authenticatedContext(uid) : env.unauthenticatedContext()).firestore();
  const schedule = (db) => F.doc(db, 'config/payout_schedule');

  test('anyone can read the schedule', async () => {
    await T.assertSucceeds(F.getDoc(schedule(dbOf(null))));
  });

  test('admin can publish a valid schedule', async () => {
    await T.assertSucceeds(F.setDoc(schedule(dbOf('admin1')), validDoc()));
  });

  test('signed-out and non-admin users cannot write', async () => {
    await T.assertFails(F.setDoc(schedule(dbOf(null)), validDoc()));
    await T.assertFails(F.setDoc(schedule(dbOf('stranger')), validDoc()));
  });

  test('admin cannot write an invalid shape', async () => {
    const db = dbOf('admin1');
    await T.assertFails(F.setDoc(schedule(db), validDoc({ programs: [] })));
    await T.assertFails(F.setDoc(schedule(db), validDoc({ programs: 'nope' })));
    await T.assertFails(F.setDoc(schedule(db), validDoc({ programs: Array.from({ length: 51 }, (_, i) => program({ id: `p${i}` })) })));
    await T.assertFails(F.setDoc(schedule(db), validDoc({ updatedAt: new Date() }))); // client clock rejected
    await T.assertFails(F.setDoc(schedule(db), validDoc({ updatedBy: 5 })));
    await T.assertFails(F.setDoc(schedule(db), { ...validDoc(), extra: true }));
  });

  test('nobody can delete the schedule', async () => {
    await T.assertFails(F.deleteDoc(schedule(dbOf('admin1'))));
  });

  test('a user can read only their own admins entry, nobody can write it', async () => {
    await T.assertSucceeds(F.getDoc(F.doc(dbOf('admin1'), 'admins/admin1')));
    await T.assertFails(F.getDoc(F.doc(dbOf('stranger'), 'admins/admin1')));
    await T.assertFails(F.getDoc(F.doc(dbOf(null), 'admins/admin1')));
    await T.assertFails(F.setDoc(F.doc(dbOf('stranger'), 'admins/stranger'), { role: 'admin' }));
    await T.assertFails(F.setDoc(F.doc(dbOf('admin1'), 'admins/another'), { role: 'admin' }));
    await T.assertFails(F.getDocs(F.collection(dbOf('admin1'), 'admins')));
  });

  test('billing data is closed to every client, even signed-in ones', async () => {
    // The app signs in anonymously to call the billing function; that must
    // not give it any direct access to purchases or entitlements.
    for (const uid of [null, 'anon-user', 'admin1']) {
      const db = dbOf(uid);
      await T.assertFails(F.getDoc(F.doc(db, 'entitlements/anon-user')));
      await T.assertFails(F.setDoc(F.doc(db, 'entitlements/anon-user'), { active: true }));
      await T.assertFails(F.getDoc(F.doc(db, 'subscriptions/abc')));
      await T.assertFails(F.setDoc(F.doc(db, 'subscriptions/abc'), { uid: 'anon-user' }));
    }
  });

  test('every other path is closed', async () => {
    await T.assertFails(F.getDoc(F.doc(dbOf('admin1'), 'users/u1')));
    await T.assertFails(F.setDoc(F.doc(dbOf('admin1'), 'config/other'), { a: 1 }));
  });
});

test('rules file exists', () => {
  assert.ok(readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8').includes('config/payout_schedule'));
});
