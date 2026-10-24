import 'package:flutter/foundation.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';

enum StorePurchaseStatus { pending, purchased, restored, canceled, error }

/// One purchase event from the store, free of any plugin types.
@immutable
class StorePurchase {
  const StorePurchase({
    required this.productId,
    required this.purchaseToken,
    required this.status,
    this.requiresCompletion = false,
    this.native,
  });

  final String productId;

  /// Proof of purchase that the server checks with Google.
  final String purchaseToken;
  final StorePurchaseStatus status;

  /// The store wants [BillingClient.complete] called (acknowledge).
  final bool requiresCompletion;

  /// The plugin's own object, handed back to [BillingClient.complete].
  final Object? native;
}

/// The store side of billing. Implemented over `in_app_purchase`; faked in
/// tests.
abstract interface class BillingClient {
  /// Every purchase update: new purchases, restores, renewals that arrived
  /// while the app was closed.
  Stream<StorePurchase> get purchases;

  Future<bool> isAvailable();

  /// Opens the store's purchase sheet. `false` when it could not be started
  /// (for example the product is not set up in the store).
  Future<bool> buy(PlusPlanType plan);

  /// Asks the store to re-deliver the user's existing purchases.
  Future<void> restore();

  /// Tells the store the purchase was delivered (acknowledges it).
  Future<void> complete(StorePurchase purchase);
}
