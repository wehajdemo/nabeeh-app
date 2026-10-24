import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/budget/presentation/fixed_expense_ui.dart';

/// One row of the "fixed deductions" list.
class FixedExpenseTile extends StatelessWidget {
  const FixedExpenseTile({
    required this.expense,
    required this.today,
    super.key,
  });

  final FixedExpense expense;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.cardSm,
      child: Row(
        children: [
          IconBadge(
            icon: expense.icon,
            background: expense.iconBackground,
            foreground: expense.iconForeground,
          ),
          const SizedBox(width: AppSpacing.gutterSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  expense.subtitle(today),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CurrencyAmount(
                amount: expense.amount,
                amountStyle: AppTypography.labelLg.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                symbolStyle: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              StatusChip(label: expense.statusLabel, tone: expense.statusTone),
            ],
          ),
        ],
      ),
    );
  }
}
