import assert from 'node:assert/strict';
import { test } from 'node:test';
import { bestEntitlement, interpretSubscription } from '../src/entitlement.mjs';
import { PRODUCTS } from '../src/products.mjs';

const NOW = Date.parse('2026-10-23T12:00:00Z');
const ctx = { now: NOW, products: PRODUCTS };

const purchase = (state, productId = 'rateby_plus_yearly', expiry = '2027-10-23T12:00:00Z', extra = {}) => ({
  subscriptionState: state,
  acknowledgementState: 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED',
  lineItems: [{ productId, expiryTime: expiry }],
  ...extra,
});

test('an active yearly subscription is entitled', () => {
  const info = interpretSubscription(purchase('SUBSCRIPTION_STATE_ACTIVE'), ctx);
  assert.equal(info.valid, true);
  assert.equal(info.entitled, true);
  assert.equal(info.plan, 'yearly');
  assert.equal(info.expiresAtMs, Date.parse('2027-10-23T12:00:00Z'));
});

test('monthly maps to the monthly plan', () => {
  const info = interpretSubscription(
    purchase('SUBSCRIPTION_STATE_ACTIVE', 'rateby_plus_monthly', '2026-11-23T12:00:00Z'),
    ctx,
  );
  assert.equal(info.plan, 'monthly');
});

test('cancelled but not yet ended still has access until the end date', () => {
  const info = interpretSubscription(purchase('SUBSCRIPTION_STATE_CANCELED'), ctx);
  assert.equal(info.entitled, true);
});

test('grace period keeps access while Google retries the payment', () => {
  const info = interpretSubscription(purchase('SUBSCRIPTION_STATE_IN_GRACE_PERIOD'), ctx);
  assert.equal(info.entitled, true);
});

for (const state of [
  'SUBSCRIPTION_STATE_ON_HOLD',
  'SUBSCRIPTION_STATE_PAUSED',
  'SUBSCRIPTION_STATE_EXPIRED',
  'SUBSCRIPTION_STATE_PENDING',
  'SUBSCRIPTION_STATE_PENDING_PURCHASE_CANCELED',
  'SOMETHING_NEW_FROM_GOOGLE',
]) {
  test(`${state} is not entitled`, () => {
    const info = interpretSubscription(purchase(state), ctx);
    assert.equal(info.valid, true);
    assert.equal(info.entitled, false);
  });
}

test('an active state whose end date has passed is not entitled', () => {
  const info = interpretSubscription(
    purchase('SUBSCRIPTION_STATE_ACTIVE', 'rateby_plus_yearly', '2026-10-23T11:59:59Z'),
    ctx,
  );
  assert.equal(info.entitled, false);
});

test('a purchase of some other product is invalid', () => {
  const info = interpretSubscription(purchase('SUBSCRIPTION_STATE_ACTIVE', 'someone_elses_sku'), ctx);
  assert.equal(info.valid, false);
  assert.equal(info.entitled, false);
});

test('inherited object keys are not products', () => {
  const info = interpretSubscription(purchase('SUBSCRIPTION_STATE_ACTIVE', 'toString'), ctx);
  assert.equal(info.valid, false);
});

test('garbage input is invalid, never entitled', () => {
  for (const bad of [null, undefined, 'x', 42, {}, { lineItems: 'no' }, { lineItems: [{ productId: 'rateby_plus_yearly', expiryTime: 'soon' }] }]) {
    const info = interpretSubscription(bad, ctx);
    assert.equal(info.valid, false);
    assert.equal(info.entitled, false);
  }
});

test('the longest-lasting line item of ours wins', () => {
  const info = interpretSubscription(
    {
      subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
      lineItems: [
        { productId: 'rateby_plus_monthly', expiryTime: '2026-11-01T00:00:00Z' },
        { productId: 'other', expiryTime: '2030-01-01T00:00:00Z' },
        { productId: 'rateby_plus_yearly', expiryTime: '2027-01-01T00:00:00Z' },
      ],
    },
    ctx,
  );
  assert.equal(info.plan, 'yearly');
});

test('a pending acknowledgement is flagged', () => {
  const info = interpretSubscription(
    purchase('SUBSCRIPTION_STATE_ACTIVE', undefined, undefined, {
      acknowledgementState: 'ACKNOWLEDGEMENT_STATE_PENDING',
    }),
    ctx,
  );
  assert.equal(info.needsAcknowledgement, true);
});

test('license-tester purchases are flagged', () => {
  const info = interpretSubscription(
    purchase('SUBSCRIPTION_STATE_ACTIVE', undefined, undefined, { testPurchase: {} }),
    ctx,
  );
  assert.equal(info.testPurchase, true);
});

test('bestEntitlement: latest live purchase wins', () => {
  const result = bestEntitlement(
    [
      { entitled: true, plan: 'monthly', expiresAtMs: NOW + 1000 },
      { entitled: true, plan: 'yearly', expiresAtMs: NOW + 99000 },
      { entitled: false, plan: 'yearly', expiresAtMs: NOW + 500000 },
    ],
    NOW,
  );
  assert.deepEqual(result, { active: true, plan: 'yearly', expiresAtMs: NOW + 99000 });
});

test('bestEntitlement: re-checks the end date against "now"', () => {
  const result = bestEntitlement([{ entitled: true, plan: 'monthly', expiresAtMs: NOW - 1 }], NOW);
  assert.equal(result.active, false);
  assert.equal(result.plan, 'monthly');
});

test('bestEntitlement: nothing known → inactive', () => {
  assert.deepEqual(bestEntitlement([], NOW), { active: false });
  assert.deepEqual(bestEntitlement([{ valid: false, entitled: false }], NOW), { active: false });
});
