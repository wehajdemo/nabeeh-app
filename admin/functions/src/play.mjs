import { androidpublisher } from '@googleapis/androidpublisher';
import { GoogleAuth } from 'google-auth-library';
import { ServiceError } from './errors.mjs';

/**
 * Google Play Developer API, authenticated as the function's own service
 * account (that account must be invited in Play Console, see README).
 */
export function createPlayClient({ packageName }) {
  const client = androidpublisher({
    version: 'v3',
    auth: new GoogleAuth({
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    }),
  });

  return {
    async getSubscription(token) {
      try {
        const { data } = await client.purchases.subscriptionsv2.get({
          packageName,
          token,
        });
        return data;
      } catch (error) {
        const status = error?.code ?? error?.response?.status;
        // 400/404/410: Google does not know this token (forged, wrong app,
        // or too old). Anything else is our outage: let it surface.
        if (status === 400 || status === 404 || status === 410) {
          throw new ServiceError('invalid-argument', 'Unknown purchase token.');
        }
        throw error;
      }
    },

    async acknowledge(productId, token) {
      await client.purchases.subscriptions.acknowledge({
        packageName,
        subscriptionId: productId,
        token,
      });
    },
  };
}
