// Google Play subscription product IDs → Plus plan.
// Keep identical to lib/features/upgrade/domain/plus_products.dart
// (test/products_sync.test.mjs fails if they drift apart).
export const PRODUCTS = Object.freeze({
  rateby_plus_monthly: 'monthly',
  rateby_plus_yearly: 'yearly',
});
