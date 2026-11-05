import 'package:flutter/material.dart';
import 'package:rateby/features/account/presentation/sign_in_prompt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/core/links/link_launcher.dart';
import 'package:rateby/features/legal/domain/legal_content.dart';
import 'package:rateby/features/legal/presentation/legal_actions.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';
import 'package:rateby/features/upgrade/application/upgrade_controller.dart';
import 'package:rateby/features/upgrade/domain/billing_config.dart';
import 'package:rateby/features/upgrade/domain/purchase_gateway.dart';
import 'package:rateby/features/upgrade/presentation/upgrade_strings.dart';
import 'package:rateby/features/upgrade/presentation/widgets/active_plan_card.dart';
import 'package:rateby/features/upgrade/presentation/widgets/benefit_tile.dart';
import 'package:rateby/features/upgrade/presentation/widgets/plans_section.dart';
import 'package:rateby/features/upgrade/presentation/widgets/plus_hero_card.dart';
import 'package:rateby/features/upgrade/presentation/widgets/subscribe_footer.dart';

/// "نبيه بلس" tab: pitch, plan choice and subscribe action.
class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  bool _isBusy = false;

  Future<void> _run(Future<PurchaseResult> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final PurchaseResult result;
    try {
      result = await action();
    } catch (_) {
      if (mounted) setState(() => _isBusy = false);
      _show(UpgradeStrings.purchaseFailed);
      return;
    }
    if (!mounted) return;
    setState(() => _isBusy = false);
    switch (result) {
      case PurchaseResult.unavailable:
        _show(UpgradeStrings.billingUnavailable);
      case PurchaseResult.purchased:
        AppToast.show(context, UpgradeStrings.purchaseDone);
      case PurchaseResult.pending:
        AppToast.show(context, UpgradeStrings.purchasePending);
      case PurchaseResult.nothingToRestore:
        _show(UpgradeStrings.nothingToRestore);
      case PurchaseResult.failed:
        _show(UpgradeStrings.purchaseFailed);
      case PurchaseResult.cancelled:
        break;
    }
  }

  /// Subscribing and restoring are tied to the account, so ask the
  /// person to sign in first (it is optional everywhere else).
  Future<void> _runSignedIn(
    SignInReason reason,
    Future<PurchaseResult> Function() action,
  ) async {
    if (!await ensureSignedIn(context, ref, reason: reason)) return;
    if (!mounted) return;
    await _run(action);
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _manage() async {
    final opened = await ref
        .read(linkLauncherProvider)
        .open(Uri.parse(BillingConfig.manageSubscriptionUrl));
    if (!opened) _show(UpgradeStrings.linkFailed);
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(upgradeControllerProvider);
    final controller = ref.read(upgradeControllerProvider.notifier);

    if (ref.watch(isPlusProvider)) {
      return ScreenBody(
        spacing: AppSpacing.lg,
        children: [
          const PlusHeroCard(),
          ActivePlanCard(
            entitlement: ref.watch(entitlementProvider),
            onManage: _manage,
          ),
          const _Benefits(),
        ],
      );
    }

    return ScreenBody(
      spacing: AppSpacing.lg,
      children: [
        const PlusHeroCard(),
        PlansSection(selected: selected, onSelected: controller.selectPlan),
        const _Benefits(),
        SubscribeFooter(
          isBusy: _isBusy,
          onSubscribe: () => _runSignedIn(SignInReason.subscribe, controller.subscribe),
          onRestore: () =>
              _runSignedIn(SignInReason.restore, controller.restorePurchases),
          onTerms: () => openLegal(context, LegalKind.terms),
          onPrivacy: () => openLegal(context, LegalKind.privacy),
          onSupport: () => openLegal(context, LegalKind.support),
        ),
      ],
    );
  }
}

class _Benefits extends StatelessWidget {
  const _Benefits();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.gutterSm,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            UpgradeStrings.benefitsTitle,
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const BenefitTile(
          icon: Icons.block,
          title: UpgradeStrings.benefitNoAdsTitle,
          body: UpgradeStrings.benefitNoAdsBody,
        ),
        const BenefitTile(
          icon: Icons.notifications_active_outlined,
          title: UpgradeStrings.benefitAlertsTitle,
          body: UpgradeStrings.benefitAlertsBody,
        ),
        const BenefitTile(
          icon: Icons.savings_outlined,
          title: UpgradeStrings.benefitGoalsTitle,
          body: UpgradeStrings.benefitGoalsBody,
        ),
        const BenefitTile(
          icon: Icons.support_agent,
          title: UpgradeStrings.benefitSupportTitle,
          body: UpgradeStrings.benefitSupportBody,
        ),
      ],
    );
  }
}
