import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';
import 'package:rateby/features/goals/presentation/goal_kind_ui.dart';
import 'package:rateby/features/goals/presentation/goals_strings.dart';

/// One savings goal: progress, saved / remaining and its monthly deduction.
class GoalCard extends StatelessWidget {
  const GoalCard({
    required this.goal,
    required this.onEdit,
    required this.onUpdateBalance,
    super.key,
  });

  final SavingsGoal goal;
  final VoidCallback onEdit;
  final VoidCallback onUpdateBalance;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          Row(
            children: [
              IconBadge(
                icon: goal.kind.icon,
                background: goal.kind.iconBackground,
                foreground: goal.kind.iconForeground,
                size: 48,
                iconSize: 26,
                borderRadius: AppRadius.card,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (goal.subtitle.isNotEmpty)
                      Text(
                        goal.subtitle,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              InfoPill(
                label: goal.isComplete
                    ? GoalsStrings.completed
                    : '${goal.percent}%',
                background: goal.isComplete
                    ? AppColors.stateSafeBackground
                    : AppColors.surfaceContainer,
                foreground: goal.isComplete
                    ? AppColors.stateSafe
                    : AppColors.onSurface,
                textStyle: AppTypography.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          AppProgressBar(
            value: goal.progress,
            height: 8,
            trackColor: AppColors.surfaceContainer,
            fill: LinearGradient(
              colors: [goal.kind.progressColor, goal.kind.progressColor],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadius.tile,
            ),
            child: Padding(
              padding: AppSpacing.cardSm,
              child: Row(
                children: [
                  Expanded(
                    child: _Amount(
                      label: GoalsStrings.saved,
                      amount: goal.saved,
                      color: AppColors.primary,
                      alignment: CrossAxisAlignment.start,
                    ),
                  ),
                  Expanded(
                    child: _Amount(
                      label: GoalsStrings.remaining,
                      amount: goal.remaining,
                      color: AppColors.onSurface,
                      alignment: CrossAxisAlignment.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Icon(Icons.autorenew, size: 18, color: AppColors.secondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: '${GoalsStrings.autoDeduct} '),
                      TextSpan(
                        text:
                            '${_format(goal.effectiveMonthly)} ${AppStrings.currencySymbol}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: ' ${GoalsStrings.perMonthShort}'),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onUpdateBalance,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(AppSizes.minTouchTarget, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  GoalsStrings.addMoney,
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(AppSizes.minTouchTarget, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      GoalsStrings.edit,
                      style: AppTypography.labelSm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _format(Money m) => MoneyFormatter.format(m);
}

class _Amount extends StatelessWidget {
  const _Amount({
    required this.label,
    required this.amount,
    required this.color,
    required this.alignment,
  });

  final String label;
  final Money amount;
  final Color color;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        CurrencyAmount(
          amount: amount,
          amountStyle: AppTypography.headlineSm.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
          symbolStyle: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
