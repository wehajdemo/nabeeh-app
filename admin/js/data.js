// Storage backends for the dashboard. Both expose the same small interface:
//   onAuthChange(cb)  signIn(email, password)  signOut()  isAdmin(user)
//   load() → {exists, programs, updatedAt, updatedBy}
//   save(programs, user, baseUpdatedAt) → {updatedAt}
// The page code never touches Firebase directly.

import { DEFAULT_PROGRAMS, fromDocumentPrograms, toDocumentPrograms } from './schedule.js';

export const SCHEDULE_PATH = ['config', 'payout_schedule'];
const FIREBASE_VERSION = '10.14.1';

/** Thrown by save() when someone else published after this page loaded. */
export class ConflictError extends Error {
  constructor() {
    super('schedule changed on the server');
    this.name = 'ConflictError';
  }
}

export function isConfigured(config) {
  return Boolean(config?.apiKey) && !String(config.apiKey).startsWith('YOUR_') &&
    !String(config.projectId ?? '').startsWith('YOUR_');
}

const sameMs = (a, b) => (a?.getTime?.() ?? null) === (b?.getTime?.() ?? null);

// ── Firebase ──────────────────────────────────────────────────────────────

/** Loads the Firebase web SDK modules from Google's CDN. */
export async function loadFirebaseSdk() {
  const base = `https://www.gstatic.com/firebasejs/${FIREBASE_VERSION}`;
  const [app, auth, fs] = await Promise.all([
    import(`${base}/firebase-app.js`),
    import(`${base}/firebase-auth.js`),
    import(`${base}/firebase-firestore.js`),
  ]);
  return { app, auth, fs };
}

/** [sdk] is injectable so the adapter can be unit-tested with a fake SDK. */
export async function createFirebaseBackend(config, sdk) {
  const { app, auth, fs } = sdk ?? await loadFirebaseSdk();

  const firebaseApp = app.initializeApp(config);
  const authInstance = auth.getAuth(firebaseApp);
  const db = fs.getFirestore(firebaseApp);
  const scheduleRef = fs.doc(db, ...SCHEDULE_PATH);
  const toUser = (u) => (u ? { uid: u.uid, email: u.email ?? '' } : null);

  return {
    mode: 'firebase',
    onAuthChange: (cb) => auth.onAuthStateChanged(authInstance, (u) => cb(toUser(u))),
    signIn: async (email, password) => {
      await auth.signInWithEmailAndPassword(authInstance, email, password);
    },
    signOut: () => auth.signOut(authInstance),

    // admins/{uid} exists → allowed to publish (created by hand in the console).
    async isAdmin(user) {
      try {
        return (await fs.getDocFromServer(fs.doc(db, 'admins', user.uid))).exists();
      } catch {
        return false;
      }
    },

    async load() {
      const snap = await fs.getDocFromServer(scheduleRef);
      if (!snap.exists()) return { exists: false, programs: [], updatedAt: null, updatedBy: null };
      const data = snap.data();
      return {
        exists: true,
        programs: fromDocumentPrograms(data),
        updatedAt: data.updatedAt?.toDate?.() ?? null,
        updatedBy: data.updatedBy ?? null,
      };
    },

    async save(programs, user, baseUpdatedAt) {
      await fs.runTransaction(db, async (tx) => {
        const current = await tx.get(scheduleRef);
        const currentAt = current.exists() ? current.data().updatedAt?.toDate?.() ?? null : null;
        if (!sameMs(currentAt, baseUpdatedAt)) throw new ConflictError();
        tx.set(scheduleRef, {
          programs: toDocumentPrograms(programs),
          updatedAt: fs.serverTimestamp(),
          updatedBy: user.email,
        });
      });
      const saved = await fs.getDocFromServer(scheduleRef);
      return { updatedAt: saved.data().updatedAt.toDate() };
    },
  };
}

// ── Demo (in-memory) ──────────────────────────────────────────────────────

/**
 * Lets you try the whole dashboard without Firebase. Data lives in memory and
 * is lost on reload. [seed] 'defaults' pre-publishes the built-in list,
 * 'empty' starts as if nothing was ever published.
 */
export function createDemoBackend({ seed = 'defaults', clock = () => new Date() } = {}) {
  const user = { uid: 'demo-admin', email: 'demo@rateby.app' };
  let signedIn = false;
  const listeners = new Set();
  let doc = seed === 'empty'
    ? null
    : {
        programs: toDocumentPrograms(DEFAULT_PROGRAMS),
        updatedAt: new Date(clock().getTime() - 2 * 86_400_000),
        updatedBy: 'مشرف سابق',
      };

  const emit = () => listeners.forEach((cb) => cb(signedIn ? user : null));
  const delay = () => new Promise((r) => setTimeout(r, 120));

  return {
    mode: 'demo',
    onAuthChange(cb) {
      listeners.add(cb);
      queueMicrotask(() => cb(signedIn ? user : null));
      return () => listeners.delete(cb);
    },
    async signIn(email, password) {
      await delay();
      if (!email || !password) throw Object.assign(new Error('bad'), { code: 'auth/invalid-credential' });
      signedIn = true;
      emit();
    },
    async signOut() {
      signedIn = false;
      emit();
    },
    async isAdmin() { return true; },

    async load() {
      await delay();
      if (!doc) return { exists: false, programs: [], updatedAt: null, updatedBy: null };
      return {
        exists: true,
        programs: fromDocumentPrograms(doc),
        updatedAt: doc.updatedAt,
        updatedBy: doc.updatedBy,
      };
    },

    async save(programs, who, baseUpdatedAt) {
      await delay();
      if (!sameMs(doc?.updatedAt ?? null, baseUpdatedAt)) throw new ConflictError();
      doc = { programs: toDocumentPrograms(programs), updatedAt: clock(), updatedBy: who.email };
      return { updatedAt: doc.updatedAt };
    },

    /** Test hook: pretend another admin published in the meantime. */
    simulateOtherAdminPublish() {
      doc = {
        programs: doc?.programs ?? toDocumentPrograms(DEFAULT_PROGRAMS),
        updatedAt: new Date(clock().getTime() + 1000),
        updatedBy: 'مشرف آخر',
      };
    },
  };
}
