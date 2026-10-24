import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';
import 'package:rateby/features/upgrade/application/play_billing_gateway.dart';
import 'package:rateby/features/upgrade/domain/billing_client.dart';
import 'package:rateby/features/upgrade/domain/purchase_gateway.dart';
import 'package:rateby/features/upgrade/domain/subscription_verifier.dart';

/// The store. `null` where billing does not exist (web, tests, builds
/// without Firebase). `main()` overrides it on Android.
final billingClientProvider = Provider<BillingClient?>((ref) => null);

/// The server check. `null` when Firebase is not configured.
final subscriptionVerifierProvider =
    Provider<SubscriptionVerifier?>((ref) => null);

/// Buys and restores subscriptions. Without both a store and a verifier
/// the app reports "billing unavailable" and nobody gets Plus.
final purchaseGatewayProvider = Provider<PurchaseGateway>((ref) {
  final client = ref.watch(billingClientProvider);
  final verifier = ref.watch(subscriptionVerifierProvider);
  if (client == null || verifier == null) {
    return const UnavailablePurchaseGateway();
  }
  final gateway = PlayBillingGateway(
    client: client,
    verifier: verifier,
    onEntitlement: (entitlement) =>
        ref.read(entitlementProvider.notifier).update(entitlement),
  )..start();
  ref.onDispose(gateway.dispose);
  return gateway;
});
