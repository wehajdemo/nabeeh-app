import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/home/presentation/widgets/fixed_expense_tile.dart';

/// Header + list of the month's fixed commitments.
class FixedExpensesSection extends StatelessWidget {
  const FixedExpensesSection({
    required this.expenses,
    required this.paidTotal,
    required this.total,
    required this.today,
    super.key,
  });

  final List<FixedExpense> expenses;
  final Money paidTotal;
  final Money total;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        SectionHeader(
          icon: Icons.receipt_long_outlined,
          title: AppStrings.fixedExpensesTitle,
          trailing: AppStrings.fixedExpensesSummary(
            MoneyFormatter.format(paidTotal),
            MoneyFormatter.format(total),
          ),
        ),
        Column(
          spacing: AppSpacing.xs,
          children: [
            for (final expense in expenses)
              FixedExpenseTile(
                key: ValueKey(expense.id),
                expense: expense,
                today: today,
              ),
          ],
        ),
      ],
    );
  }
}
