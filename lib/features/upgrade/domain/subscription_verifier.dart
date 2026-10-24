import 'package:rateby/features/upgrade/domain/plus_entitlement.dart';

/// Server-side proof that a purchase is real. The server asks Google Play,
/// so a modified app cannot grant itself Plus.
abstract interface class SubscriptionVerifier {
  /// Checks a new purchase and returns the account's entitlement.
  Future<PlusEntitlement> verify({
    required String productId,
    required String purchaseToken,
  });

  /// Re-checks the purchases the server already knows for this account.
  Future<PlusEntitlement> refresh();
}
