import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rateby/features/upgrade/domain/billing_client.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';
import 'package:rateby/features/upgrade/domain/plus_products.dart';

/// [BillingClient] over the `in_app_purchase` plugin (Google Play Billing).
class InAppPurchaseBillingClient implements BillingClient {
  InAppPurchaseBillingClient([InAppPurchase? iap])
      : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;

  @override
  Stream<StorePurchase> get purchases =>
      _iap.purchaseStream.expand((updates) => updates.map(_map));

  @override
  Future<bool> isAvailable() => _iap.isAvailable();

  @override
  Future<bool> buy(PlusPlanType plan) async {
    final id = PlusProducts.idFor(plan);
    final response = await _iap.queryProductDetails({id});
    final options = response.productDetails.where((d) => d.id == id).toList();
    if (options.isEmpty) return false;
    // Play lists one entry per offer the user may take. The free-trial offer
    // starts at 0, so the cheapest entry is the trial when the user is
    // eligible for it and the plain base plan when they already used it.
    options.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    return _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: options.first),
    );
  }

  @override
  Future<void> restore() => _iap.restorePurchases();

  @override
  Future<void> complete(StorePurchase purchase) async {
    final native = purchase.native;
    if (native is PurchaseDetails) await _iap.completePurchase(native);
  }

  StorePurchase _map(PurchaseDetails details) => StorePurchase(
        productId: details.productID,
        purchaseToken: details.verificationData.serverVerificationData,
        status: switch (details.status) {
          PurchaseStatus.pending => StorePurchaseStatus.pending,
          PurchaseStatus.purchased => StorePurchaseStatus.purchased,
          PurchaseStatus.restored => StorePurchaseStatus.restored,
          PurchaseStatus.canceled => StorePurchaseStatus.canceled,
          PurchaseStatus.error => StorePurchaseStatus.error,
        },
        requiresCompletion: details.pendingCompletePurchase,
        native: details,
      );
}
