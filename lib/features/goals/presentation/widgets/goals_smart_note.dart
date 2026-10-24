import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/goals/application/goals_state.dart';
import 'package:rateby/features/goals/presentation/goals_strings.dart';

/// Explains how goal deductions feed the daily spending limit.
class GoalsSmartNote extends StatelessWidget {
  const GoalsSmartNote({required this.state, super.key});

  final GoalsState state;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surfaceContainerLow,
      shadows: const [],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(
            icon: Icons.lightbulb_outline,
            background: AppColors.tertiaryFixed,
            foreground: AppColors.onTertiaryFixed,
            size: 36,
          ),
          const SizedBox(width: AppSpacing.gutterSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                Text(
                  GoalsStrings.smartTitle,
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  GoalsStrings.smartBody(
                    MoneyFormatter.format(state.monthlyDeductions),
                    state.payDay,
                  ),
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
