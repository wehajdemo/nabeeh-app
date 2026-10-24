import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/providers/clock_provider.dart';
import 'package:rateby/features/upgrade/application/billing_providers.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';
import 'package:rateby/features/upgrade/application/entitlement_refresh.dart';
import 'package:rateby/features/upgrade/domain/entitlement_cache.dart';
import 'package:rateby/features/upgrade/domain/plus_entitlement.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';
import 'package:rateby/features/upgrade/domain/purchase_gateway.dart';

import '../../support/fake_billing.dart';
import '../../support/test_overrides.dart';

void main() {
  late DateTime now;
  late FakeVerifier verifier;

  ProviderContainer make(PlusEntitlement? cached, {bool withVerifier = true}) {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(() => now),
        entitlementCacheProvider
            .overrideWithValue(MemoryEntitlementCache(cached)),
        if (withVerifier) subscriptionVerifierProvider.overrideWithValue(verifier),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    now = testNow;
    verifier = FakeVerifier();
  });

  final subscribed = PlusEntitlement(
    active: true,
    plan: PlusPlanType.monthly,
    expiresAt: testNow.add(const Duration(days: 20)),
  );

  test('a cancelled or refunded subscription is picked up from the server',
      () async {
    verifier.result = const PlusEntitlement.none();
    final container = make(subscribed);
    expect(container.read(isPlusProvider), isTrue);

    await container.read(entitlementRefreshProvider).run();

    expect(container.read(isPlusProvider), isFalse);
  });

  test('a renewal extends the end date', () async {
    final renewed = PlusEntitlement(
      active: true,
      plan: PlusPlanType.monthly,
      expiresAt: testNow.add(const Duration(days: 50)),
    );
    verifier.result = renewed;
    final container = make(subscribed);

    await container.read(entitlementRefreshProvider).run();

    expect(container.read(entitlementProvider), renewed);
  });

  test('people who never subscribed cost no network call', () async {
    final container = make(null);

    await container.read(entitlementRefreshProvider).run();

    expect(verifier.refreshCalls, 0);
  });

  test('offline keeps the cached entitlement', () async {
    verifier.error = Exception('offline');
    final container = make(subscribed);

    await container.read(entitlementRefreshProvider).run();

    expect(container.read(entitlementProvider), subscribed);
    expect(container.read(isPlusProvider), isTrue);
  });

  test('checks are throttled while the subscription is valid', () async {
    final container = make(subscribed);
    final refresh = container.read(entitlementRefreshProvider);

    await refresh.run();
    await refresh.run();
    expect(verifier.refreshCalls, 1);

    now = now.add(EntitlementRefresh.minInterval + const Duration(minutes: 1));
    await refresh.run();
    expect(verifier.refreshCalls, 2);
  });

  test('an expired entitlement is re-checked immediately', () async {
    final lapsed = PlusEntitlement(
      active: true,
      plan: PlusPlanType.monthly,
      expiresAt: testNow.subtract(const Duration(hours: 1)),
    );
    verifier.result = lapsed; // the server also says it has ended
    final container = make(lapsed);
    expect(container.read(isPlusProvider), isFalse, reason: 'ends offline too');
    final refresh = container.read(entitlementRefreshProvider);

    await refresh.run();
    await refresh.run();

    expect(verifier.refreshCalls, 2);
  });

  test('without billing configured the gateway reports unavailable', () async {
    final container = make(null, withVerifier: false);
    final gateway = container.read(purchaseGatewayProvider);

    expect(await gateway.purchase(PlusPlanType.yearly), PurchaseResult.unavailable);
    expect(await gateway.restore(), PurchaseResult.unavailable);
  });
}
