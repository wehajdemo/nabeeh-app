import 'dart:async';

import 'package:rateby/features/upgrade/domain/billing_client.dart';
import 'package:rateby/features/upgrade/domain/plus_entitlement.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';
import 'package:rateby/features/upgrade/domain/subscription_verifier.dart';

/// Store double: tests push purchase events through [emit]; [onBuy] and
/// [onRestore] decide how the store reacts to the user's actions.
class FakeBillingClient implements BillingClient {
  final StreamController<StorePurchase> _controller =
      StreamController<StorePurchase>.broadcast();

  bool available = true;
  bool canLaunch = true;
  void Function(PlusPlanType plan)? onBuy;
  void Function()? onRestore;

  final List<PlusPlanType> bought = [];
  final List<StorePurchase> completed = [];
  int restoreCalls = 0;

  void emit(StorePurchase purchase) => _controller.add(purchase);

  @override
  Stream<StorePurchase> get purchases => _controller.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> buy(PlusPlanType plan) async {
    bought.add(plan);
    if (!canLaunch) return false;
    // Deliver after buy() returns, like the real store does.
    scheduleMicrotask(() => onBuy?.call(plan));
    return true;
  }

  @override
  Future<void> restore() async {
    restoreCalls++;
    scheduleMicrotask(() => onRestore?.call());
  }

  @override
  Future<void> complete(StorePurchase purchase) async =>
      completed.add(purchase);

  Future<void> close() => _controller.close();
}

/// Server double.
class FakeVerifier implements SubscriptionVerifier {
  FakeVerifier({
    this.result = const PlusEntitlement(active: true, plan: PlusPlanType.yearly),
  });

  PlusEntitlement result;
  Object? error;
  final List<({String productId, String token})> verified = [];
  int refreshCalls = 0;

  @override
  Future<PlusEntitlement> verify({
    required String productId,
    required String purchaseToken,
  }) async {
    verified.add((productId: productId, token: purchaseToken));
    final e = error;
    if (e != null) throw e;
    return result;
  }

  @override
  Future<PlusEntitlement> refresh() async {
    refreshCalls++;
    final e = error;
    if (e != null) throw e;
    return result;
  }
}

StorePurchase storePurchase({
  String productId = 'rateby_plus_yearly',
  String token = 'tok-1',
  StorePurchaseStatus status = StorePurchaseStatus.purchased,
  bool requiresCompletion = true,
}) =>
    StorePurchase(
      productId: productId,
      purchaseToken: token,
      status: status,
      requiresCompletion: requiresCompletion,
    );
