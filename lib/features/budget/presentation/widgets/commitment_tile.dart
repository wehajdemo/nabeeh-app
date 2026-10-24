import 'package:flutter/material.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/budget/presentation/budget_strings.dart';
import 'package:rateby/features/budget/presentation/fixed_expense_ui.dart';

/// A fixed commitment with its amount and a remove button.
class CommitmentTile extends StatelessWidget {
  const CommitmentTile({
    required this.title,
    required this.amount,
    required this.category,
    required this.onRemove,
    super.key,
  });

  final String title;
  final Money amount;
  final FixedExpenseCategory category;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          IconBadge(
            icon: category.icon,
            background: category.iconBackground,
            foreground: category.iconForeground,
            size: 48,
            iconSize: 24,
            borderRadius: AppRadius.card,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  category.description,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CurrencyAmount(
            amount: amount,
            amountStyle: AppTypography.labelLg.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
            symbolStyle: AppTypography.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: BudgetStrings.removeCommitment,
            icon: Icon(
              Icons.close,
              size: 20,
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}
