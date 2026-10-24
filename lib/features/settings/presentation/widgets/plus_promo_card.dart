import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_shadows.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/features/settings/presentation/settings_strings.dart';

/// Gradient upsell card for "نبيه بلس".
class PlusPromoCard extends StatelessWidget {
  const PlusPromoCard({
    required this.monthlyPrice,
    required this.onUpgrade,
    super.key,
  });

  /// Already formatted, e.g. `9`.
  final String monthlyPrice;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerEnd,
          end: AlignmentDirectional.centerStart,
          colors: [AppColors.hero.primary, AppColors.hero.primaryContainer],
        ),
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: AppSpacing.cardMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.gutterSm,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xs,
                    children: [
                      const _PlusBadge(),
                      Text(
                        SettingsStrings.plusTitle,
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.hero.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        SettingsStrings.plusBody,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.hero.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.hero.onPrimary10,
                    borderRadius: AppRadius.card,
                  ),
                  child: SizedBox.square(
                    dimension: 48,
                    child: Icon(
                      Icons.workspace_premium_outlined,
                      size: 28,
                      color: AppColors.hero.primaryFixed,
                    ),
                  ),
                ),
              ],
            ),
            FilledButton(
              onPressed: onUpgrade,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.hero.secondaryContainer,
                foregroundColor: AppColors.hero.onSecondaryContainer,
                minimumSize: const Size.fromHeight(AppSizes.minTouchTarget),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.tile,
                ),
                textStyle: AppTypography.labelLg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(SettingsStrings.plusCta(monthlyPrice)),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlusBadge extends StatelessWidget {
  const _PlusBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.hero.secondaryContainer,
        borderRadius: AppRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars,
              size: 14,
              color: AppColors.hero.onSecondaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              SettingsStrings.plusBadge,
              style: AppTypography.labelSm.copyWith(
                color: AppColors.hero.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
