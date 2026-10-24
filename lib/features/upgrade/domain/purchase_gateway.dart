import 'package:rateby/features/upgrade/domain/plus_plan.dart';

enum PurchaseResult {
  /// Billing is not wired up in this build or the store is unreachable.
  unavailable,
  purchased,
  cancelled,
  failed,

  /// The payment is still being processed (for example cash or carrier
  /// billing). Plus turns on by itself once it completes.
  pending,

  /// A restore found no active subscription for this account.
  nothingToRestore,
}

/// Billing boundary. The UI only knows this interface.
abstract interface class PurchaseGateway {
  Future<PurchaseResult> purchase(PlusPlanType plan);
  Future<PurchaseResult> restore();
}

/// Default gateway: reports that billing is unavailable.
class UnavailablePurchaseGateway implements PurchaseGateway {
  const UnavailablePurchaseGateway();

  @override
  Future<PurchaseResult> purchase(PlusPlanType plan) async =>
      PurchaseResult.unavailable;

  @override
  Future<PurchaseResult> restore() async => PurchaseResult.unavailable;
}
