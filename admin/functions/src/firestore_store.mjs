// Persistence on Firestore (Admin SDK, so security rules do not apply).
//
//   subscriptions/{sha256(token)}  → { uid, token, productId, info, ... }
//   entitlements/{uid}             → { active, plan, expiresAtMs, updatedAtMs }
//
// Both collections are closed to clients by firestore.rules.

export function createFirestoreStore(db) {
  const tokens = db.collection('subscriptions');
  const entitlements = db.collection('entitlements');

  return {
    async getToken(hash) {
      const snap = await tokens.doc(hash).get();
      return snap.exists ? snap.data() : null;
    },

    async putToken(hash, record) {
      await tokens.doc(hash).set(record);
    },

    async listTokens(uid, limit) {
      // Equality filter only (no composite index needed); an account holds
      // a handful of purchases at most, so sorting here is cheap.
      const snap = await tokens.where('uid', '==', uid).limit(50).get();
      return snap.docs
        .map((d) => d.data())
        .sort((a, b) => (b.claimedAtMs ?? 0) - (a.claimedAtMs ?? 0))
        .slice(0, limit);
    },

    async putEntitlement(uid, entitlement) {
      await entitlements.doc(uid).set(entitlement);
    },
  };
}
