import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/goals/presentation/goals_strings.dart';

/// Shown when no goal exists yet.
class GoalsEmptyState extends StatelessWidget {
  const GoalsEmptyState({required this.onCreate, super.key});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.cardLg,
      child: Column(
        spacing: AppSpacing.md,
        children: [
          IconBadge(
            icon: Icons.savings_outlined,
            background: AppColors.primaryFixed,
            foreground: AppColors.onPrimaryFixed,
            size: 56,
            iconSize: 28,
            borderRadius: AppRadius.card,
          ),
          Text(
            GoalsStrings.emptyTitle,
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          Text(
            GoalsStrings.emptyBody,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          PrimaryButton(
            label: GoalsStrings.newGoal,
            icon: Icons.add,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}
