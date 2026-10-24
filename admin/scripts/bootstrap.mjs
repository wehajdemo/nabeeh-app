#!/usr/bin/env node
// One-time setup helper (run on YOUR machine, not in the browser):
//   - finds or creates the admin's Firebase Auth user
//   - adds admins/{uid}, so the rules let that user publish
//   - optionally publishes the built-in payout list as the first schedule
//
//   npm install
//   gcloud auth application-default login            # or set GOOGLE_APPLICATION_CREDENTIALS
//   node scripts/bootstrap.mjs --project my-proj --email me@example.com [--password '...'] [--seed]
import { DEFAULT_PROGRAMS, toDocumentPrograms } from '../js/schedule.js';

const args = process.argv.slice(2);
const opt = (name) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 ? args[i + 1] : undefined;
};
const project = opt('project');
const email = opt('email');
const password = opt('password');
const seed = args.includes('--seed');

if (!project || !email) {
  console.error('Usage: node scripts/bootstrap.mjs --project <id> --email <admin email> [--password <pw>] [--seed]');
  process.exit(1);
}

const { initializeApp, applicationDefault } = await import('firebase-admin/app');
const { getAuth } = await import('firebase-admin/auth');
const { getFirestore, FieldValue } = await import('firebase-admin/firestore');

initializeApp({ projectId: project, credential: applicationDefault() });
const auth = getAuth();
const db = getFirestore();

let user;
try {
  user = await auth.getUserByEmail(email);
  console.log(`Found user ${email} (${user.uid})`);
} catch (error) {
  if (error.code !== 'auth/user-not-found') throw error;
  if (!password || password.length < 8) {
    console.error('No such user. Pass --password (8+ characters) to create it.');
    process.exit(1);
  }
  user = await auth.createUser({ email, password, emailVerified: true });
  console.log(`Created user ${email} (${user.uid})`);
}

await db.doc(`admins/${user.uid}`).set({ role: 'admin', email, createdAt: FieldValue.serverTimestamp() });
console.log(`admins/${user.uid} written`);

if (seed) {
  const ref = db.doc('config/payout_schedule');
  if ((await ref.get()).exists) {
    console.log('config/payout_schedule already exists — not overwritten.');
  } else {
    await ref.set({
      programs: toDocumentPrograms(DEFAULT_PROGRAMS),
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: email,
    });
    console.log('Published the built-in schedule.');
  }
}
console.log('Done. Sign in to the dashboard with this e-mail.');
