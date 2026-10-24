import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { setGlobalOptions } from 'firebase-functions/v2';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { onMessagePublished } from 'firebase-functions/v2/pubsub';
import { defineString } from 'firebase-functions/params';
import * as logger from 'firebase-functions/logger';
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

initializeApp();

let service;
function getService() {
  service ??= createEntitlementService({
    play: createPlayClient({ packageName: packageName.value() }),
    store: createFirestoreStore(getFirestore()),
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
  const { productId, purchaseToken } = request.data ?? {};
  try {
    const { active, plan, expiresAtMs } = await getService().sync({
      uid,
      productId,
      purchaseToken,
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
