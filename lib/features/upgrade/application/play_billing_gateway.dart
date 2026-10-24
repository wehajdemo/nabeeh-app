import 'dart:async';

import 'package:rateby/features/upgrade/domain/billing_client.dart';
import 'package:rateby/features/upgrade/domain/plus_entitlement.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';
import 'package:rateby/features/upgrade/domain/purchase_gateway.dart';
import 'package:rateby/features/upgrade/domain/subscription_verifier.dart';

/// Buys through the store and unlocks Plus only after the server confirmed
/// the purchase with Google.
///
/// A purchase is "completed" (acknowledged) only after the server accepted
/// it. If the server cannot be reached the purchase stays open: the store
/// delivers it again on the next launch, so a paid subscription is never
/// lost, and Google refunds purchases that are never acknowledged.
class PlayBillingGateway implements PurchaseGateway {
  PlayBillingGateway({
    required BillingClient client,
    required SubscriptionVerifier verifier,
    required Future<void> Function(PlusEntitlement entitlement) onEntitlement,
    this.purchaseTimeout = const Duration(minutes: 5),
    this.restoreWait = const Duration(seconds: 6),
  })  : _client = client,
        _verifier = verifier,
        _onEntitlement = onEntitlement;

  final BillingClient _client;
  final SubscriptionVerifier _verifier;
  final Future<void> Function(PlusEntitlement entitlement) _onEntitlement;
  final Duration purchaseTimeout;
  final Duration restoreWait;

  StreamSubscription<StorePurchase>? _subscription;
  Completer<PurchaseResult>? _waiting;

  /// Starts listening to the store. Call once at app start so purchases that
  /// finish later (slow payment methods, renewals) are still delivered.
  void start() {
    _subscription ??= _client.purchases.listen(
      (purchase) => unawaited(_handle(purchase)),
      onError: (Object _) => _finish(PurchaseResult.failed),
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<PurchaseResult> purchase(PlusPlanType plan) async {
    start();
    if (_waiting != null) return PurchaseResult.failed;
    if (!await _client.isAvailable()) return PurchaseResult.unavailable;
    final waiting = _waiting = Completer<PurchaseResult>();
    try {
      if (!await _client.buy(plan)) return PurchaseResult.unavailable;
      return await waiting.future.timeout(
        purchaseTimeout,
        onTimeout: () => PurchaseResult.failed,
      );
    } on Object {
      return PurchaseResult.failed;
    } finally {
      if (identical(_waiting, waiting)) _waiting = null;
    }
  }

  @override
  Future<PurchaseResult> restore() async {
    start();
    if (_waiting != null) return PurchaseResult.failed;
    if (!await _client.isAvailable()) return PurchaseResult.unavailable;
    final waiting = _waiting = Completer<PurchaseResult>();
    try {
      await _client.restore();
      // The store sends nothing when there is nothing to restore, so a
      // quiet period means "none"; then ask the server what it knows.
      final fromStore = await waiting.future.timeout(
        restoreWait,
        onTimeout: () => PurchaseResult.nothingToRestore,
      );
      if (fromStore != PurchaseResult.nothingToRestore) return fromStore;
      final entitlement = await _verifier.refresh();
      await _onEntitlement(entitlement);
      return entitlement.active
          ? PurchaseResult.purchased
          : PurchaseResult.nothingToRestore;
    } on Object {
      return PurchaseResult.failed;
    } finally {
      if (identical(_waiting, waiting)) _waiting = null;
    }
  }

  Future<void> _handle(StorePurchase purchase) async {
    switch (purchase.status) {
      case StorePurchaseStatus.pending:
        _finish(PurchaseResult.pending);
      case StorePurchaseStatus.canceled:
        _finish(PurchaseResult.cancelled);
      case StorePurchaseStatus.error:
        _finish(PurchaseResult.failed);
      case StorePurchaseStatus.purchased:
      case StorePurchaseStatus.restored:
        await _deliver(purchase);
    }
  }

  Future<void> _deliver(StorePurchase purchase) async {
    final PlusEntitlement entitlement;
    try {
      entitlement = await _verifier.verify(
        productId: purchase.productId,
        purchaseToken: purchase.purchaseToken,
      );
      await _onEntitlement(entitlement);
    } on Object {
      // Leave the purchase open; the store re-delivers it later.
      _finish(PurchaseResult.failed);
      return;
    }
    if (purchase.requiresCompletion) {
      try {
        await _client.complete(purchase);
      } on Object {
        // The server already acknowledged it; nothing to do.
      }
    }
    if (entitlement.active) {
      _finish(PurchaseResult.purchased);
    } else {
      _finish(
        purchase.status == StorePurchaseStatus.restored
            ? PurchaseResult.nothingToRestore
            : PurchaseResult.failed,
      );
    }
  }

  void _finish(PurchaseResult result) {
    final waiting = _waiting;
    if (waiting != null && !waiting.isCompleted) waiting.complete(result);
  }
}
