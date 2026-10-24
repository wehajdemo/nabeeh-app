import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/features/upgrade/application/play_billing_gateway.dart';
import 'package:rateby/features/upgrade/domain/billing_client.dart';
import 'package:rateby/features/upgrade/domain/plus_entitlement.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';
import 'package:rateby/features/upgrade/domain/purchase_gateway.dart';

import '../../support/fake_billing.dart';

class Harness {
  Harness() {
    gateway = PlayBillingGateway(
      client: client,
      verifier: verifier,
      onEntitlement: (e) async => granted.add(e),
      purchaseTimeout: const Duration(milliseconds: 300),
      restoreWait: const Duration(milliseconds: 60),
    );
    addTearDown(() async {
      await gateway.dispose();
      await client.close();
    });
  }

  final client = FakeBillingClient();
  final verifier = FakeVerifier();
  final granted = <PlusEntitlement>[];
  late final PlayBillingGateway gateway;
}

void main() {
  test('a purchase is verified by the server, granted, then completed',
      () async {
    final h = Harness();
    h.client.onBuy = (_) => h.client.emit(storePurchase());

    final result = await h.gateway.purchase(PlusPlanType.yearly);

    expect(result, PurchaseResult.purchased);
    expect(h.client.bought, [PlusPlanType.yearly]);
    expect(h.verifier.verified, [(productId: 'rateby_plus_yearly', token: 'tok-1')]);
    expect(h.granted.single.active, isTrue);
    expect(h.client.completed, hasLength(1));
  });

  test('cancelling grants nothing', () async {
    final h = Harness();
    h.client.onBuy = (_) =>
        h.client.emit(storePurchase(status: StorePurchaseStatus.canceled));

    expect(await h.gateway.purchase(PlusPlanType.monthly), PurchaseResult.cancelled);
    expect(h.granted, isEmpty);
    expect(h.verifier.verified, isEmpty);
  });

  test('a store error is a failure', () async {
    final h = Harness();
    h.client.onBuy = (_) =>
        h.client.emit(storePurchase(status: StorePurchaseStatus.error));

    expect(await h.gateway.purchase(PlusPlanType.monthly), PurchaseResult.failed);
    expect(h.granted, isEmpty);
  });

  test('a payment that is still processing is reported as pending', () async {
    final h = Harness();
    h.client.onBuy = (_) =>
        h.client.emit(storePurchase(status: StorePurchaseStatus.pending));

    expect(await h.gateway.purchase(PlusPlanType.monthly), PurchaseResult.pending);
    expect(h.granted, isEmpty);
    expect(h.client.completed, isEmpty);
  });

  test('when the server is unreachable Plus is NOT granted and the purchase '
      'stays open for the store to re-deliver', () async {
    final h = Harness()..verifier.error = Exception('offline');
    h.client.onBuy = (_) => h.client.emit(storePurchase());

    final result = await h.gateway.purchase(PlusPlanType.yearly);

    expect(result, PurchaseResult.failed);
    expect(h.granted, isEmpty);
    expect(h.client.completed, isEmpty);
  });

  test('a purchase the server rejects does not unlock Plus', () async {
    final h = Harness();
    h.verifier.result = const PlusEntitlement.none();
    h.client.onBuy = (_) => h.client.emit(storePurchase());

    final result = await h.gateway.purchase(PlusPlanType.yearly);

    expect(result, PurchaseResult.failed);
    expect(h.granted.single.active, isFalse);
  });

  test('billing unavailable on the device', () async {
    final h = Harness()..client.available = false;
    expect(await h.gateway.purchase(PlusPlanType.yearly), PurchaseResult.unavailable);
    expect(h.client.bought, isEmpty);
  });

  test('a product missing in the store reports unavailable', () async {
    final h = Harness()..client.canLaunch = false;
    expect(await h.gateway.purchase(PlusPlanType.yearly), PurchaseResult.unavailable);
  });

  test('a purchase delivered when nobody is waiting (app start) is still '
      'verified and granted', () async {
    final h = Harness()..gateway.start();

    h.client.emit(storePurchase(token: 'late', status: StorePurchaseStatus.restored));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(h.verifier.verified.single.token, 'late');
    expect(h.granted.single.active, isTrue);
    expect(h.client.completed, hasLength(1));
  });

  test('restore: the store re-delivers the purchase', () async {
    final h = Harness();
    h.client.onRestore = () => h.client
        .emit(storePurchase(status: StorePurchaseStatus.restored));

    expect(await h.gateway.restore(), PurchaseResult.purchased);
    expect(h.client.restoreCalls, 1);
  });

  test('restore: a quiet store falls back to what the server knows', () async {
    final h = Harness();

    expect(await h.gateway.restore(), PurchaseResult.purchased);
    expect(h.verifier.refreshCalls, 1);
    expect(h.granted.single.active, isTrue);
  });

  test('restore: nothing anywhere → nothing to restore', () async {
    final h = Harness();
    h.verifier.result = const PlusEntitlement.none();

    expect(await h.gateway.restore(), PurchaseResult.nothingToRestore);
  });

  test('a second purchase while one is open is refused', () async {
    final h = Harness();
    // No onBuy: the first purchase waits for the store.
    final first = h.gateway.purchase(PlusPlanType.yearly);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(await h.gateway.purchase(PlusPlanType.monthly), PurchaseResult.failed);
    expect(await first, PurchaseResult.failed, reason: 'timed out');
  });
}
