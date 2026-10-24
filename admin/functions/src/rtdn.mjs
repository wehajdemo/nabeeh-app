/**
 * Reads a Google Play real-time developer notification.
 * `payload` is the already base64-decoded JSON string of the Pub/Sub message.
 *
 * @returns {{ kind: 'subscription'|'voided'|'test'|'ignored',
 *             packageName?: string, purchaseToken?: string }}
 */
export function parseNotification(payload) {
  let data;
  try {
    data = JSON.parse(payload);
  } catch {
    return { kind: 'ignored' };
  }
  if (!data || typeof data !== 'object') return { kind: 'ignored' };
  const packageName =
    typeof data.packageName === 'string' ? data.packageName : undefined;

  if (data.testNotification) return { kind: 'test', packageName };

  const sub = data.subscriptionNotification;
  if (sub && typeof sub.purchaseToken === 'string') {
    return { kind: 'subscription', packageName, purchaseToken: sub.purchaseToken };
  }
  const voided = data.voidedPurchaseNotification;
  if (voided && typeof voided.purchaseToken === 'string') {
    return { kind: 'voided', packageName, purchaseToken: voided.purchaseToken };
  }
  return { kind: 'ignored', packageName };
}
