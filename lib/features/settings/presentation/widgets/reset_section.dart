import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/features/settings/presentation/settings_strings.dart';

/// Destructive "start over" block. Only triggers [onReset]; the screen asks
/// for confirmation.
class ResetSection extends StatelessWidget {
  const ResetSection({required this.onReset, super.key});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.3),
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.cardMd,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 40,
                child: Icon(Icons.warning_amber_rounded, color: AppColors.error),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xs,
                children: [
                  Text(
                    SettingsStrings.resetTitle,
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    SettingsStrings.resetBody,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FilledButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.delete_forever_outlined, size: 18),
                    label: const Text(SettingsStrings.resetButton),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.onError,
                      minimumSize: const Size(0, AppSizes.minTouchTarget),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.tile,
                      ),
                      textStyle: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
