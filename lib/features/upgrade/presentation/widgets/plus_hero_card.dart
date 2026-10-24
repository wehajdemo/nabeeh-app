import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_shadows.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';
import 'package:rateby/features/upgrade/presentation/upgrade_strings.dart';

/// Gradient hero: crown, name, tagline and three trust stats.
class PlusHeroCard extends StatelessWidget {
  const PlusHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.elevated,
      ),
      child: Padding(
        padding: AppSpacing.cardLg,
        child: Column(
          spacing: AppSpacing.sm,
          children: [
            const _Crown(),
            InfoPill(
              icon: Icons.verified_outlined,
              iconColor: AppColors.hero.secondaryFixed,
              label: UpgradeStrings.heroBadge,
              background: AppColors.hero.onPrimary15,
              foreground: AppColors.hero.onPrimary,
              textStyle: AppTypography.labelSm,
            ),
            Text(
              UpgradeStrings.heroTitle,
              style: AppTypography.headlineLg.copyWith(
                color: AppColors.hero.onPrimary,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                UpgradeStrings.heroBody,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.hero.primaryFixedDim,
                ),
              ),
            ),
            const _TrustStats(),
          ],
        ),
      ),
    );
  }
}

class _Crown extends StatelessWidget {
  const _Crown();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.hero.onPrimary15,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: 64,
            child: Icon(
              Icons.workspace_premium,
              size: 36,
              color: AppColors.hero.tertiaryFixedDim,
            ),
          ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: Dot(color: AppColors.hero.secondaryContainer, size: 14),
        ),
      ],
    );
  }
}

class _TrustStats extends StatelessWidget {
  const _TrustStats();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.hero.onPrimary10,
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.cardSm,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _Stat(
                  value: UpgradeStrings.trialDays(PlusPlan.trialDays),
                  label: UpgradeStrings.statTrial,
                  valueColor: AppColors.hero.onPrimary,
                ),
              ),
              VerticalDivider(width: 1, color: AppColors.hero.onPrimary10),
              Expanded(
                child: _Stat(
                  value: UpgradeStrings.statAdsValue,
                  label: UpgradeStrings.statAdsLabel,
                  valueColor: AppColors.hero.secondaryFixed,
                ),
              ),
              VerticalDivider(width: 1, color: AppColors.hero.onPrimary10),
              Expanded(
                child: _Stat(
                  value: UpgradeStrings.statCancelValue,
                  label: UpgradeStrings.statCancelLabel,
                  valueColor: AppColors.hero.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.labelLg.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSm.copyWith(color: AppColors.hero.outlineVariant),
        ),
      ],
    );
  }
}
