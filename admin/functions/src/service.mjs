import { createHash } from 'node:crypto';
import { bestEntitlement, interpretSubscription } from './entitlement.mjs';
import { ServiceError } from './errors.mjs';
import { PRODUCTS } from './products.mjs';

const MAX_TOKEN_LENGTH = 4096;
const MAX_TOKENS_PER_ACCOUNT = 5;

export function hashToken(token) {
  return createHash('sha256').update(token).digest('hex');
}

/**
 * The billing rules, free of Firebase and Google types so they can be
 * tested with plain fakes.
 *
 * @param {{
 *   play: { getSubscription(token:string): Promise<object>,
 *           acknowledge(productId:string, token:string): Promise<void> },
 *   store: {
 *     getToken(hash:string): Promise<object|null>,
 *     putToken(hash:string, record:object): Promise<void>,
 *     listTokens(uid:string, limit:number): Promise<object[]>,
 *     putEntitlement(uid:string, entitlement:object): Promise<void>,
 *   },
 *   products?: Record<string,string>,
 *   now?: () => number,
 * }} deps
 */
export function createEntitlementService({
  play,
  store,
  products = PRODUCTS,
  now = Date.now,
}) {
  /** Reads Google's view of one purchase token and remembers it. */
  async function checkToken(uid, token, { claim }) {
    const purchase = await play.getSubscription(token);
    const info = interpretSubscription(purchase, { now: now(), products });
    if (!info.valid) {
      throw new ServiceError(
        'invalid-argument',
        'The purchase does not belong to a Plus product.',
      );
    }
    // Only a paid purchase may be acknowledged; Google rejects the rest.
    if (info.needsAcknowledgement && info.entitled) {
      await play.acknowledge(info.productId, token);
    }
    const hash = hashToken(token);
    const existing = await store.getToken(hash);
    const previousUid = existing?.uid;
    await store.putToken(hash, {
      uid,
      token,
      productId: info.productId,
      info,
      checkedAtMs: now(),
      claimedAtMs: claim || previousUid !== uid ? now() : existing.claimedAtMs,
    });
    return { info, previousUid };
  }

  /** Combines everything known about an account into its entitlement. */
  async function settle(uid, records) {
    const entitlement = bestEntitlement(
      records.map((r) => r.info),
      now(),
    );
    await store.putEntitlement(uid, { ...entitlement, updatedAtMs: now() });
    return entitlement;
  }

  /** Re-asks Google about every purchase this account owns. */
  async function refreshAccount(uid) {
    const records = await store.listTokens(uid, MAX_TOKENS_PER_ACCOUNT);
    const fresh = [];
    for (const record of records) {
      try {
        const { info } = await checkToken(uid, record.token, { claim: false });
        fresh.push({ info });
      } catch (error) {
        if (error instanceof ServiceError) {
          // Google no longer recognises it: it cannot grant anything.
          continue;
        }
        // Google unreachable: do not take Plus away because of our outage;
        // keep what was last known.
        fresh.push({ info: record.info });
      }
    }
    return settle(uid, fresh);
  }

  return {
    /**
     * @param {{ uid: string, productId?: string, purchaseToken?: string }} request
     * @returns {Promise<{active:boolean, plan?:string, expiresAtMs?:number}>}
     */
    async sync({ uid, productId, purchaseToken }) {
      if (typeof uid !== 'string' || uid === '') {
        throw new ServiceError('unauthenticated', 'Sign-in required.');
      }
      if (purchaseToken === undefined || purchaseToken === null) {
        return refreshAccount(uid);
      }
      if (
        typeof purchaseToken !== 'string' ||
        purchaseToken === '' ||
        purchaseToken.length > MAX_TOKEN_LENGTH
      ) {
        throw new ServiceError('invalid-argument', 'Bad purchase token.');
      }
      if (productId !== undefined && !Object.hasOwn(products, productId)) {
        throw new ServiceError('invalid-argument', 'Unknown product.');
      }

      const { previousUid } = await checkToken(uid, purchaseToken, {
        claim: true,
      });

      // The same purchase now belongs to this account (restore after a
      // reinstall gives the app a new anonymous identity). Take it away from
      // the old account so one purchase unlocks one account at a time.
      if (previousUid && previousUid !== uid) {
        await refreshAccount(previousUid);
      }
      return refreshAccount(uid);
    },

    /**
     * A Play notification (renewal, cancellation, refund...) arrived for a
     * token. Unknown tokens are ignored: the app has not claimed them yet.
     */
    async handleTokenEvent(purchaseToken) {
      if (typeof purchaseToken !== 'string' || purchaseToken === '') {
        return null;
      }
      const record = await store.getToken(hashToken(purchaseToken));
      if (!record?.uid) return null;
      return refreshAccount(record.uid);
    },
  };
}
