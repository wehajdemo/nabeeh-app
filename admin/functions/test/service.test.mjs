import assert from 'node:assert/strict';
import { beforeEach, test } from 'node:test';
import { ServiceError } from '../src/errors.mjs';
import { createEntitlementService, hashToken } from '../src/service.mjs';
import { fakePlay, fakeStore, playPurchase } from './fakes.mjs';

const NOW = Date.parse('2026-10-23T12:00:00Z');
const YEAR_END = Date.parse('2027-10-23T12:00:00Z');

let play;
let store;
let clock;
let service;

beforeEach(() => {
  play = fakePlay();
  store = fakeStore();
  clock = NOW;
  service = createEntitlementService({ play, store, now: () => clock });
});

test('a real purchase unlocks Plus and is acknowledged', async () => {
  play.purchases.set('tok-a', playPurchase());

  const result = await service.sync({
    uid: 'u1',
    productId: 'rateby_plus_yearly',
    purchaseToken: 'tok-a',
  });

  assert.deepEqual(result, { active: true, plan: 'yearly', expiresAtMs: YEAR_END });
  assert.deepEqual(play.acknowledged, [{ productId: 'rateby_plus_yearly', token: 'tok-a' }]);
  assert.equal(store.entitlements.get('u1').active, true);
  assert.equal(store.tokens.get(hashToken('tok-a')).uid, 'u1');
});

test('the raw token is never used as a document id', async () => {
  play.purchases.set('tok/with/slashes', playPurchase());
  await service.sync({ uid: 'u1', purchaseToken: 'tok/with/slashes' });
  for (const key of store.tokens.keys()) assert.match(key, /^[0-9a-f]{64}$/);
});

test('a forged token grants nothing', async () => {
  await assert.rejects(
    service.sync({ uid: 'u1', productId: 'rateby_plus_yearly', purchaseToken: 'made-up' }),
    (e) => e instanceof ServiceError && e.code === 'invalid-argument',
  );
  assert.equal(store.entitlements.size, 0);
  assert.equal(store.tokens.size, 0);
});

test('a purchase of another product is rejected', async () => {
  play.purchases.set('tok-x', playPurchase({ productId: 'other_app_sku' }));
  await assert.rejects(
    service.sync({ uid: 'u1', purchaseToken: 'tok-x' }),
    (e) => e.code === 'invalid-argument',
  );
  assert.equal(store.entitlements.size, 0);
});

test('an unknown productId in the request is rejected before calling Google', async () => {
  await assert.rejects(
    service.sync({ uid: 'u1', productId: 'free_stuff', purchaseToken: 'tok' }),
    (e) => e.code === 'invalid-argument',
  );
  assert.equal(play.calls.length, 0);
});

test('bad tokens and missing sign-in are rejected', async () => {
  await assert.rejects(service.sync({ uid: 'u1', purchaseToken: '' }), (e) => e.code === 'invalid-argument');
  await assert.rejects(service.sync({ uid: 'u1', purchaseToken: 'x'.repeat(5000) }), (e) => e.code === 'invalid-argument');
  await assert.rejects(service.sync({ uid: 'u1', purchaseToken: 42 }), (e) => e.code === 'invalid-argument');
  await assert.rejects(service.sync({ uid: '', purchaseToken: 't' }), (e) => e.code === 'unauthenticated');
  assert.equal(play.calls.length, 0);
});

test('a purchase that is not paid yet is not acknowledged and grants nothing', async () => {
  play.purchases.set('tok-p', playPurchase({ state: 'SUBSCRIPTION_STATE_PENDING' }));
  const result = await service.sync({ uid: 'u1', purchaseToken: 'tok-p' });
  assert.equal(result.active, false);
  assert.deepEqual(play.acknowledged, []);
});

test('an already acknowledged purchase is not acknowledged twice', async () => {
  play.purchases.set('tok-a', playPurchase({ acknowledged: true }));
  await service.sync({ uid: 'u1', purchaseToken: 'tok-a' });
  assert.deepEqual(play.acknowledged, []);
});

test('refresh with no token re-checks what the account owns', async () => {
  play.purchases.set('tok-a', playPurchase({ productId: 'rateby_plus_monthly', expiry: '2026-11-20T00:00:00Z', acknowledged: true }));
  await service.sync({ uid: 'u1', purchaseToken: 'tok-a' });

  // The user cancels and the paid month runs out.
  play.purchases.set('tok-a', playPurchase({ productId: 'rateby_plus_monthly', expiry: '2026-11-20T00:00:00Z', state: 'SUBSCRIPTION_STATE_EXPIRED', acknowledged: true }));
  clock = Date.parse('2026-11-21T00:00:00Z');

  const result = await service.sync({ uid: 'u1' });
  assert.equal(result.active, false);
  assert.equal(store.entitlements.get('u1').active, false);
});

test('a refund (voided purchase) removes Plus on the next refresh', async () => {
  play.purchases.set('tok-a', playPurchase({ acknowledged: true }));
  await service.sync({ uid: 'u1', purchaseToken: 'tok-a' });

  play.purchases.set('tok-a', playPurchase({ state: 'SUBSCRIPTION_STATE_EXPIRED', expiry: '2026-10-23T11:00:00Z', acknowledged: true }));
  const result = await service.sync({ uid: 'u1' });

  assert.equal(result.active, false);
});

test('a renewal extends the end date', async () => {
  play.purchases.set('tok-a', playPurchase({ productId: 'rateby_plus_monthly', expiry: '2026-11-23T12:00:00Z', acknowledged: true }));
  await service.sync({ uid: 'u1', purchaseToken: 'tok-a' });
  play.purchases.set('tok-a', playPurchase({ productId: 'rateby_plus_monthly', expiry: '2026-12-23T12:00:00Z', acknowledged: true }));

  const result = await service.sync({ uid: 'u1' });

  assert.equal(result.expiresAtMs, Date.parse('2026-12-23T12:00:00Z'));
});

test('upgrading monthly → yearly: the longer purchase wins', async () => {
  play.purchases.set('tok-m', playPurchase({ productId: 'rateby_plus_monthly', expiry: '2026-11-23T12:00:00Z', acknowledged: true }));
  await service.sync({ uid: 'u1', purchaseToken: 'tok-m' });
  clock += 1000;
  play.purchases.set('tok-y', playPurchase({ acknowledged: true }));

  const result = await service.sync({ uid: 'u1', purchaseToken: 'tok-y' });

  assert.equal(result.plan, 'yearly');
  assert.equal(result.expiresAtMs, YEAR_END);
});

test('Google being down never takes Plus away', async () => {
  play.purchases.set('tok-a', playPurchase({ acknowledged: true }));
  await service.sync({ uid: 'u1', purchaseToken: 'tok-a' });

  play.down = true;
  const result = await service.sync({ uid: 'u1' });

  assert.equal(result.active, true);
});

test('Google being down on a NEW purchase is an error, not a grant', async () => {
  play.down = true;
  await assert.rejects(
    service.sync({ uid: 'u1', purchaseToken: 'tok-new' }),
    (e) => !(e instanceof ServiceError),
  );
  assert.equal(store.entitlements.size, 0);
});

test('restoring on a new install moves the purchase to the new account', async () => {
  play.purchases.set('tok-a', playPurchase({ acknowledged: true }));
  await service.sync({ uid: 'old-install', purchaseToken: 'tok-a' });
  clock += 1000;

  const restored = await service.sync({ uid: 'new-install', purchaseToken: 'tok-a' });

  assert.equal(restored.active, true);
  assert.equal(store.entitlements.get('new-install').active, true);
  assert.equal(store.entitlements.get('old-install').active, false, 'one purchase, one account');
  assert.equal(store.tokens.get(hashToken('tok-a')).uid, 'new-install');
});

test('a refresh for an account with no purchases is simply inactive', async () => {
  assert.deepEqual(await service.sync({ uid: 'nobody' }), { active: false });
});

test('a Play notification refreshes the owner of the token', async () => {
  play.purchases.set('tok-a', playPurchase({ acknowledged: true }));
  await service.sync({ uid: 'u1', purchaseToken: 'tok-a' });
  play.purchases.set('tok-a', playPurchase({ state: 'SUBSCRIPTION_STATE_EXPIRED', expiry: '2026-10-23T11:00:00Z', acknowledged: true }));

  const result = await service.handleTokenEvent('tok-a');

  assert.equal(result.active, false);
  assert.equal(store.entitlements.get('u1').active, false);
});

test('a notification for a token nobody claimed is ignored', async () => {
  assert.equal(await service.handleTokenEvent('unknown'), null);
  assert.equal(await service.handleTokenEvent(''), null);
  assert.equal(await service.handleTokenEvent(undefined), null);
  assert.equal(play.calls.length, 0);
});
