// In-memory stand-ins for Google Play and Firestore.

export function fakePlay() {
  const purchases = new Map(); // token → SubscriptionPurchaseV2
  const play = {
    purchases,
    acknowledged: [],
    calls: [],
    down: false,
    async getSubscription(token) {
      play.calls.push(token);
      if (play.down) throw new Error('Google is down');
      const purchase = purchases.get(token);
      if (!purchase) {
        const { ServiceError } = await import('../src/errors.mjs');
        throw new ServiceError('invalid-argument', 'Unknown purchase token.');
      }
      return structuredClone(purchase);
    },
    async acknowledge(productId, token) {
      play.acknowledged.push({ productId, token });
      const purchase = purchases.get(token);
      if (purchase) purchase.acknowledgementState = 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED';
    },
  };
  return play;
}

export function fakeStore() {
  const tokens = new Map();
  const entitlements = new Map();
  return {
    tokens,
    entitlements,
    async getToken(hash) {
      return tokens.get(hash) ?? null;
    },
    async putToken(hash, record) {
      tokens.set(hash, structuredClone(record));
    },
    async listTokens(uid, limit) {
      return [...tokens.values()]
        .filter((t) => t.uid === uid)
        .sort((a, b) => b.claimedAtMs - a.claimedAtMs)
        .slice(0, limit)
        .map((t) => structuredClone(t));
    },
    async putEntitlement(uid, entitlement) {
      entitlements.set(uid, structuredClone(entitlement));
    },
  };
}

export const playPurchase = ({
  productId = 'rateby_plus_yearly',
  state = 'SUBSCRIPTION_STATE_ACTIVE',
  expiry = '2027-10-23T12:00:00Z',
  acknowledged = false,
} = {}) => ({
  subscriptionState: state,
  acknowledgementState: acknowledged
    ? 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED'
    : 'ACKNOWLEDGEMENT_STATE_PENDING',
  lineItems: [{ productId, expiryTime: expiry }],
});
