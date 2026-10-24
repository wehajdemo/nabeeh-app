import assert from 'node:assert/strict';
import { test } from 'node:test';
import { parseNotification } from '../src/rtdn.mjs';

test('subscription notification', () => {
  const note = parseNotification(JSON.stringify({
    version: '1.0',
    packageName: 'com.example.rateby',
    eventTimeMillis: '1',
    subscriptionNotification: { version: '1.0', notificationType: 2, purchaseToken: 'tok', subscriptionId: 'rateby_plus_yearly' },
  }));
  assert.deepEqual(note, { kind: 'subscription', packageName: 'com.example.rateby', purchaseToken: 'tok' });
});

test('voided purchase (refund) notification', () => {
  const note = parseNotification(JSON.stringify({
    packageName: 'p',
    voidedPurchaseNotification: { purchaseToken: 'tok', orderId: 'GPA.1', productType: 1 },
  }));
  assert.equal(note.kind, 'voided');
  assert.equal(note.purchaseToken, 'tok');
});

test('test notification from Play Console', () => {
  assert.equal(parseNotification(JSON.stringify({ packageName: 'p', testNotification: { version: '1.0' } })).kind, 'test');
});

test('anything else is ignored', () => {
  for (const bad of ['', 'not json', 'null', '42', '{}', JSON.stringify({ subscriptionNotification: {} })]) {
    assert.equal(parseNotification(bad).kind, 'ignored');
  }
});
