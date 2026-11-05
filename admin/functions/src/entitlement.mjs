// Turns a Google Play `SubscriptionPurchaseV2` into "does this person have
// Plus right now?". Pure: no network, no clock of its own.

// States in which the user is entitled to the service:
//  - ACTIVE: paid and renewing.
//  - CANCELED: auto-renew is off, but the paid period has not ended yet.
//  - IN_GRACE_PERIOD: renewal payment failed, Google keeps access on while
//    it retries.
// Everything else (ON_HOLD, PAUSED, EXPIRED, PENDING, ...) is not entitled.
export const ENTITLED_STATES = new Set([
  'SUBSCRIPTION_STATE_ACTIVE',
  'SUBSCRIPTION_STATE_CANCELED',
  'SUBSCRIPTION_STATE_IN_GRACE_PERIOD',
]);

/**
 * @param {object} purchase  SubscriptionPurchaseV2 from the Play API.
 * @param {{ now: number, products: Record<string,string> }} ctx
 * @returns {{
 *   valid: boolean, productId?: string, plan?: string, state?: string,
 *   expiresAtMs?: number, entitled: boolean, needsAcknowledgement: boolean,
 *   testPurchase: boolean
 * }}
 */
export function interpretSubscription(purchase, { now, products }) {
  const none = {
    valid: false,
    entitled: false,
    needsAcknowledgement: false,
    testPurchase: false,
  };
  if (!purchase || typeof purchase !== 'object') return none;

  // A purchase can hold several line items (add-ons); only ours count.
  // If there are several of ours, the one that lasts longest wins.
  const ours = (Array.isArray(purchase.lineItems) ? purchase.lineItems : [])
    .filter((item) => item && Object.hasOwn(products, item.productId))
    .map((item) => ({ item, expiresAtMs: Date.parse(item.expiryTime) }))
    .filter(({ expiresAtMs }) => Number.isFinite(expiresAtMs))
    .sort((a, b) => b.expiresAtMs - a.expiresAtMs);
  if (ours.length === 0) return none;

  const { item, expiresAtMs } = ours[0];
  const state = String(purchase.subscriptionState ?? '');
  return {
    valid: true,
    productId: item.productId,
    plan: products[item.productId],
    state,
    expiresAtMs,
    entitled: ENTITLED_STATES.has(state) && expiresAtMs > now,
    needsAcknowledgement:
      purchase.acknowledgementState === 'ACKNOWLEDGEMENT_STATE_PENDING',
    testPurchase: purchase.testPurchase != null,
  };
}

/**
 * Turns a verified StoreKit 2 transaction into the same shape as
 * [interpretSubscription]. Pure.
 *
 * @param {object} tx  JWSTransactionDecodedPayload (signature already checked).
 * @param {{ now: number, products: Record<string,string> }} ctx
 */
export function interpretAppleTransaction(tx, { now, products }) {
  const none = {
    valid: false,
    entitled: false,
    needsAcknowledgement: false,
    testPurchase: false,
  };
  if (!tx || typeof tx !== 'object') return none;
  if (!Object.hasOwn(products, tx.productId)) return none;
  if (typeof tx.originalTransactionId !== 'string' || tx.originalTransactionId === '') {
    return none;
  }
  const expiresAtMs = Number(tx.expiresDate);
  if (!Number.isFinite(expiresAtMs)) return none;

  const revoked = tx.revocationDate != null;
  const state = revoked
    ? 'APPLE_REVOKED'
    : expiresAtMs > now
      ? 'APPLE_ACTIVE'
      : 'APPLE_EXPIRED';
  return {
    valid: true,
    productId: tx.productId,
    plan: products[tx.productId],
    state,
    expiresAtMs,
    entitled: state === 'APPLE_ACTIVE',
    needsAcknowledgement: false,
    testPurchase: tx.environment !== 'Production',
    revoked,
  };
}

/**
 * Apple sends one transaction per renewal, and the app may re-send an old
 * one. Keep the latest period, but a refund always wins.
 */
export function mergeAppleInfo(previous, next) {
  if (!previous?.valid || next.revoked) return next;
  return next.expiresAtMs >= previous.expiresAtMs ? next : previous;
}

/**
 * The best of several purchases of one account: an entitled one with the
 * latest end date, otherwise the latest ended one (so the app can show when
 * it ended), otherwise "none".
 *
 * @param {Array<{entitled:boolean, plan?:string, expiresAtMs?:number}>} infos
 * @param {number} now  entitlement is re-evaluated against this instant
 */
export function bestEntitlement(infos, now) {
  const live = infos
    .filter((i) => i.valid !== false && i.entitled && i.expiresAtMs > now)
    .sort((a, b) => b.expiresAtMs - a.expiresAtMs);
  if (live.length > 0) {
    const { plan, expiresAtMs } = live[0];
    return { active: true, plan, expiresAtMs };
  }
  const past = infos
    .filter((i) => i.valid !== false && Number.isFinite(i.expiresAtMs))
    .sort((a, b) => b.expiresAtMs - a.expiresAtMs);
  if (past.length > 0) {
    const { plan, expiresAtMs } = past[0];
    return { active: false, plan, expiresAtMs };
  }
  return { active: false };
}
