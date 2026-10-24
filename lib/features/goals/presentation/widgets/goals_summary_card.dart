import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_shadows.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/goals/application/goals_state.dart';
import 'package:rateby/features/goals/presentation/goals_strings.dart';

/// Gradient hero with total savings, overall progress and monthly deduction.
class GoalsSummaryCard extends StatelessWidget {
  const GoalsSummaryCard({required this.state, super.key});

  final GoalsState state;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.md,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.hero.onPrimary15,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: 32,
                    child: Icon(
                      Icons.savings_outlined,
                      size: 18,
                      color: AppColors.hero.secondaryFixed,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    GoalsStrings.totalSaved,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.hero.onPrimary80,
                    ),
                  ),
                ),
                InfoPill(
                  label: GoalsStrings.achievement(state.achievementPercent),
                  background: AppColors.hero.secondaryContainer30,
                  foreground: AppColors.hero.secondaryFixed,
                  leading: Dot(color: AppColors.hero.secondaryFixed, size: 6),
                  textStyle: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  MoneyFormatter.format(state.totalSaved),
                  style: AppTypography.displayHeroMobile.copyWith(
                    color: AppColors.hero.onPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  AppStrings.currencySymbol,
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.hero.primaryFixed,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    GoalsStrings.ofTotal(MoneyFormatter.format(state.totalTarget)),
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.hero.onPrimary75,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            AppProgressBar(
              value: state.progress,
              height: 10,
              inset: 2,
              trackColor: AppColors.hero.primary40,
              fill: AppColors.progressSafe,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    GoalsStrings.remainingToFreedom(
                      MoneyFormatter.format(state.remaining),
                    ),
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.hero.onPrimary80,
                    ),
                  ),
                ),
                Text(
                  GoalsStrings.activeGoals(state.activeCount),
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.hero.onPrimary80,
                  ),
                ),
              ],
            ),
            Divider(height: 1, color: AppColors.hero.onPrimary10),
            Row(
              children: [
                Icon(
                  Icons.sync_alt,
                  size: 16,
                  color: AppColors.hero.secondaryFixed,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    GoalsStrings.totalDeduction,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.hero.onPrimary80,
                    ),
                  ),
                ),
                Text(
                  GoalsStrings.perMonth(
                    MoneyFormatter.format(state.monthlyDeductions),
                  ),
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.hero.secondaryFixed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
