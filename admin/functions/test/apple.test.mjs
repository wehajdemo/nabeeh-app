import assert from 'node:assert/strict';
import { beforeEach, test } from 'node:test';
import { ServiceError } from '../src/errors.mjs';
import { createEntitlementService, hashToken } from '../src/service.mjs';
import {
  appleTransaction,
  fakeApple,
  fakePlay,
  fakeStore,
  playPurchase,
} from './fakes.mjs';

const NOW = Date.parse('2026-10-23T12:00:00Z');
const YEAR_END = Date.parse('2027-10-23T12:00:00Z');
const MONTH_END = Date.parse('2026-11-23T12:00:00Z');
const KEY = hashToken('apple:2000000111');

let play;
let store;
let apple;
let clock;
let service;

beforeEach(() => {
  play = fakePlay();
  store = fakeStore();
  apple = fakeApple();
  clock = NOW;
  service = createEntitlementService({ play, store, apple, now: () => clock });
});

test('a signed App Store transaction unlocks Plus', async () => {
  apple.transactions.set('jws-1', appleTransaction());

  const result = await service.sync({ uid: 'u1', purchaseToken: 'jws-1', store: 'apple' });

  assert.deepEqual(result, { active: true, plan: 'yearly', expiresAtMs: YEAR_END });
  const record = store.tokens.get(KEY);
  assert.equal(record.uid, 'u1');
  assert.equal(record.store, 'apple');
  assert.equal(play.calls.length, 0, 'Google is never asked about Apple purchases');
});

test('a transaction with a bad signature grants nothing', async () => {
  await assert.rejects(
    service.sync({ uid: 'u1', purchaseToken: 'forged', store: 'apple' }),
    (e) => e instanceof ServiceError && e.code === 'invalid-argument',
  );
  assert.equal(store.tokens.size, 0);
  assert.equal(store.entitlements.size, 0);
});

test('another app product is rejected', async () => {
  apple.transactions.set('jws-x', appleTransaction({ productId: 'something_else' }));
  await assert.rejects(
    service.sync({ uid: 'u1', purchaseToken: 'jws-x', store: 'apple' }),
    (e) => e.code === 'invalid-argument',
  );
});

test('an expired period is recorded but not entitled', async () => {
  apple.transactions.set('jws-old', appleTransaction({ expiresDate: NOW - 1000 }));
  const result = await service.sync({ uid: 'u1', purchaseToken: 'jws-old', store: 'apple' });
  assert.equal(result.active, false);
});

test('an old transaction re-sent after a renewal does not shorten Plus', async () => {
  apple.transactions.set('jws-new', appleTransaction({ expiresDate: YEAR_END }));
  apple.transactions.set('jws-older', appleTransaction({ expiresDate: MONTH_END }));
  await service.sync({ uid: 'u1', purchaseToken: 'jws-new', store: 'apple' });

  const result = await service.sync({ uid: 'u1', purchaseToken: 'jws-older', store: 'apple' });

  assert.equal(result.expiresAtMs, YEAR_END);
});

test('a refund removes Plus even if the period has not ended', async () => {
  apple.transactions.set('jws-1', appleTransaction());
  apple.transactions.set('jws-refunded', appleTransaction({ revocationDate: NOW }));
  await service.sync({ uid: 'u1', purchaseToken: 'jws-1', store: 'apple' });

  const result = await service.sync({ uid: 'u1', purchaseToken: 'jws-refunded', store: 'apple' });

  assert.equal(result.active, false);
});

test('one purchase unlocks one account at a time', async () => {
  apple.transactions.set('jws-1', appleTransaction());
  await service.sync({ uid: 'u1', purchaseToken: 'jws-1', store: 'apple' });

  await service.sync({ uid: 'u2', purchaseToken: 'jws-1', store: 'apple' });

  assert.equal(store.entitlements.get('u2').active, true);
  assert.equal(store.entitlements.get('u1').active, false);
});

test('a refresh keeps the stored App Store state and ends it on time', async () => {
  apple.transactions.set('jws-m', appleTransaction({ expiresDate: MONTH_END }));
  await service.sync({ uid: 'u1', purchaseToken: 'jws-m', store: 'apple' });

  assert.equal((await service.sync({ uid: 'u1' })).active, true);
  clock = MONTH_END + 1;
  assert.equal((await service.sync({ uid: 'u1' })).active, false);
});

test('Google and Apple purchases of one account are combined', async () => {
  play.purchases.set('tok-g', playPurchase({ productId: 'rateby_plus_monthly', expiry: '2026-11-23T12:00:00Z' }));
  apple.transactions.set('jws-1', appleTransaction({ expiresDate: YEAR_END }));
  await service.sync({ uid: 'u1', purchaseToken: 'tok-g' });

  const result = await service.sync({ uid: 'u1', purchaseToken: 'jws-1', store: 'apple' });

  assert.deepEqual(result, { active: true, plan: 'yearly', expiresAtMs: YEAR_END });
});

test('a renewal notification extends Plus for the owner', async () => {
  apple.transactions.set('jws-m', appleTransaction({ expiresDate: MONTH_END }));
  await service.sync({ uid: 'u1', purchaseToken: 'jws-m', store: 'apple' });
  apple.transactions.set('jws-renewed', appleTransaction({ expiresDate: YEAR_END }));
  apple.notifications.set('note-1', {
    notificationType: 'DID_RENEW',
    data: { signedTransactionInfo: 'jws-renewed' },
  });

  const result = await service.handleAppleNotification('note-1');

  assert.equal(result.expiresAtMs, YEAR_END);
  assert.equal(store.entitlements.get('u1').expiresAtMs, YEAR_END);
});

test('a notification for an unclaimed purchase is ignored', async () => {
  apple.transactions.set('jws-1', appleTransaction());
  apple.notifications.set('note-1', {
    notificationType: 'SUBSCRIBED',
    data: { signedTransactionInfo: 'jws-1' },
  });
  assert.equal(await service.handleAppleNotification('note-1'), null);
  assert.equal(store.tokens.size, 0);
});

test('a TEST notification without a transaction does nothing', async () => {
  apple.notifications.set('note-test', { notificationType: 'TEST', data: {} });
  assert.equal(await service.handleAppleNotification('note-test'), null);
});

test('App Store purchases are refused when Apple is not configured', async () => {
  const noApple = createEntitlementService({ play, store, now: () => clock });
  await assert.rejects(
    noApple.sync({ uid: 'u1', purchaseToken: 'jws-1', store: 'apple' }),
    (e) => e.code === 'failed-precondition',
  );
});

test('an unknown store name is rejected', async () => {
  await assert.rejects(
    service.sync({ uid: 'u1', purchaseToken: 'x', store: 'amazon' }),
    (e) => e.code === 'invalid-argument',
  );
});

test('deleting the account forgets its purchases and entitlement', async () => {
  apple.transactions.set('jws-1', appleTransaction());
  await service.sync({ uid: 'u1', purchaseToken: 'jws-1', store: 'apple' });

  await service.deleteAccount('u1');

  assert.equal(store.tokens.size, 0);
  assert.equal(store.entitlements.has('u1'), false);
});
