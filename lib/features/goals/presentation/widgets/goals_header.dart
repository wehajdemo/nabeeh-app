import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/features/goals/presentation/goals_strings.dart';

/// Screen title with the "new goal" shortcut.
class GoalsHeader extends StatelessWidget {
  const GoalsHeader({required this.onNewGoal, super.key});

  final VoidCallback onNewGoal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                GoalsStrings.title,
                style: AppTypography.headlineLg.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                GoalsStrings.subtitle,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        FilledButton.icon(
          onPressed: onNewGoal,
          icon: const Icon(Icons.add, size: 20),
          label: const Text(GoalsStrings.newGoal),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(0, AppSizes.minTouchTarget),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            shape: const StadiumBorder(),
            textStyle: AppTypography.labelLg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
