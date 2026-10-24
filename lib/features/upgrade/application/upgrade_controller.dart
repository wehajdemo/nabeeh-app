import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/features/upgrade/application/billing_providers.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';
import 'package:rateby/features/upgrade/domain/purchase_gateway.dart';

/// Selected plan and the purchase actions of the Upgrade tab.
class UpgradeController extends Notifier<PlusPlanType> {
  @override
  PlusPlanType build() => PlusPlanType.yearly;

  void selectPlan(PlusPlanType plan) => state = plan;

  Future<PurchaseResult> subscribe() =>
      ref.read(purchaseGatewayProvider).purchase(state);

  Future<PurchaseResult> restorePurchases() =>
      ref.read(purchaseGatewayProvider).restore();
}

final upgradeControllerProvider =
    NotifierProvider<UpgradeController, PlusPlanType>(UpgradeController.new);
