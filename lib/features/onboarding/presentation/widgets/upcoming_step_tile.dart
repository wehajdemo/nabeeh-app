import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';

/// Muted preview of a later step ("Next: commitments").
class UpcomingStepTile extends StatelessWidget {
  const UpcomingStepTile({
    required this.number,
    required this.title,
    required this.note,
    super.key,
  });

  final int number;
  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surfaceContainerLow,
      shadows: const [],
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: 36,
              child: Center(
                child: Text(
                  '$number',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  note,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Mirrors in RTL so it points toward the reading direction.
          Icon(Icons.chevron_right, color: AppColors.outline),
        ],
      ),
    );
  }
}
