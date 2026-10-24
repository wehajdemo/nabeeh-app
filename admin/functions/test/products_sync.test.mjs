import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import { PRODUCTS } from '../src/products.mjs';

const dartFile = new URL('../../../lib/features/upgrade/domain/plus_products.dart', import.meta.url);
const dart = readFileSync(dartFile, 'utf8');

const idOf = (name) => dart.match(new RegExp(`static const String ${name}Id = '([^']+)'`))?.[1];

test('product IDs in the app and the server are identical', () => {
  assert.equal(PRODUCTS[idOf('monthly')], 'monthly');
  assert.equal(PRODUCTS[idOf('yearly')], 'yearly');
  assert.equal(Object.keys(PRODUCTS).length, 2);
});

test('the server entry point loads (imports resolve, exports exist)', async () => {
  process.env.GCLOUD_PROJECT ??= 'demo-rateby';
  const mod = await import('../index.js');
  assert.equal(typeof mod.syncEntitlement, 'function');
  assert.equal(typeof mod.playNotifications, 'function');
});
