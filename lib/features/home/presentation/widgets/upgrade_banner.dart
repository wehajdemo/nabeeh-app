import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';

/// Sponsored upsell strip for "نبيه بلس".
class UpgradeBanner extends StatelessWidget {
  const UpgradeBanner({required this.onUpgrade, super.key});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.cardSm,
      color: AppColors.surfaceContainerHigh,
      child: Row(
        children: [
          IconBadge(
            icon: Icons.verified_user_outlined,
            background: AppColors.primaryFixed,
            foreground: AppColors.onPrimaryFixedVariant,
            size: 36,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InfoPill(
                      label: AppStrings.sponsoredTag,
                      background: AppColors.surfaceContainer,
                      foreground: AppColors.onSurfaceVariant,
                      textStyle: AppTypography.labelXs.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        AppStrings.upgradeBannerTitle,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  AppStrings.upgradeBannerBody,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: onUpgrade,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.tile),
              textStyle: AppTypography.labelSm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text(AppStrings.upgradeCta),
          ),
        ],
      ),
    );
  }
}
