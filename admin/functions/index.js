import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { setGlobalOptions } from 'firebase-functions/v2';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { onRequest } from 'firebase-functions/v2/https';
import { onMessagePublished } from 'firebase-functions/v2/pubsub';
import { auth } from 'firebase-functions/v1';
import { defineString } from 'firebase-functions/params';
import * as logger from 'firebase-functions/logger';
import { createAppleVerifier } from './src/apple.mjs';
import { ServiceError } from './src/errors.mjs';
import { createFirestoreStore } from './src/firestore_store.mjs';
import { createPlayClient } from './src/play.mjs';
import { parseNotification } from './src/rtdn.mjs';
import { createEntitlementService } from './src/service.mjs';

// Must equal BillingConfig.functionsRegion in the Flutter app.
setGlobalOptions({ region: 'us-central1', maxInstances: 10 });

// Asked for once at deploy time (firebase deploy --only functions).
const packageName = defineString('PLAY_PACKAGE_NAME', {
  description: 'Android applicationId of the app in Google Play',
});

const appleBundleId = defineString('APPLE_BUNDLE_ID', {
  default: 'com.rateby.rateby',
  description: 'Bundle id of the iPhone app',
});

// Numeric Apple ID of the app (App Store Connect → App Information). Needed
// only for production purchases; TestFlight and App Review use the sandbox.
const appleAppId = defineString('APPLE_APP_ID', {
  default: '0',
  description: 'Numeric Apple ID of the app in App Store Connect (0 = sandbox only)',
});

initializeApp();

let service;
function getService() {
  const appAppleId = Number(appleAppId.value()) || undefined;
  service ??= createEntitlementService({
    play: createPlayClient({ packageName: packageName.value() }),
    store: createFirestoreStore(getFirestore()),
    apple: createAppleVerifier({ bundleId: appleBundleId.value(), appAppleId }),
  });
  return service;
}

/**
 * Called by the app after a purchase (with productId + purchaseToken) and
 * when it starts (with no data, to refresh). The caller is identified by
 * Firebase Auth (anonymous sign-in is enough); the proof of payment is the
 * token, which is checked with Google Play here.
 */
export const syncEntitlement = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Sign-in required.');
  // Subscriptions belong to a Google account, so they follow the person to a
  // new phone. Anonymous sessions (older builds) are not accepted.
  if (request.auth?.token?.firebase?.sign_in_provider === 'anonymous') {
    throw new HttpsError('unauthenticated', 'Google sign-in required.');
  }
  const { productId, purchaseToken, store } = request.data ?? {};
  try {
    const { active, plan, expiresAtMs } = await getService().sync({
      uid,
      productId,
      purchaseToken,
      store,
    });
    return { active, plan: plan ?? null, expiresAtMs: expiresAtMs ?? null };
  } catch (error) {
    if (error instanceof ServiceError) {
      throw new HttpsError(error.code, error.message);
    }
    logger.error('syncEntitlement failed', error);
    throw new HttpsError('internal', 'Could not verify the purchase.');
  }
});

/**
 * Optional: Google Play real-time notifications (renewals, cancellations,
 * refunds) through the Pub/Sub topic `play-rtdn`. Without it the app still
 * picks changes up whenever it refreshes.
 */
export const playNotifications = onMessagePublished('play-rtdn', async (event) => {
  const payload = Buffer.from(event.data.message.data ?? '', 'base64').toString('utf8');
  const note = parseNotification(payload);
  if (note.kind === 'ignored' || note.kind === 'test') return;
  if (note.packageName !== packageName.value()) return;
  await getService().handleTokenEvent(note.purchaseToken);
});

/**
 * Optional: App Store Server Notifications V2 (renewals, expiry, refunds).
 * Set this function's URL in App Store Connect → App Information →
 * App Store Server Notifications. The payload is signed by Apple and
 * checked here, so the URL itself needs no secret.
 */
export const appStoreNotifications = onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).send('');
    return;
  }
  try {
    await getService().handleAppleNotification(req.body?.signedPayload);
    res.status(200).send('');
  } catch (error) {
    if (error instanceof ServiceError) {
      res.status(400).send('');
      return;
    }
    logger.error('appStoreNotifications failed', error);
    // Non-2xx makes Apple retry later.
    res.status(500).send('');
  }
});

/**
 * Account deletion (Settings → حذف الحساب): removes the backup, the
 * entitlement and the purchase records tied to the account.
 */
export const deleteUserData = auth.user().onDelete(async (user) => {
  await getService().deleteAccount(user.uid);
});
