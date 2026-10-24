import 'package:flutter/foundation.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/daily_allowance.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/budget/domain/entities/salary_cycle.dart';

/// Everything the dashboard needs, as of a moment in time.
@immutable
class BudgetSnapshot {
  const BudgetSnapshot({
    required this.allowance,
    required this.salaryCycle,
    required this.fixedExpenses,
    required this.monthlyCommitmentsTotal,
  });

  final DailyAllowance allowance;
  final SalaryCycle salaryCycle;
  final List<FixedExpense> fixedExpenses;

  /// All fixed commitments for the cycle (may exceed the items listed).
  final Money monthlyCommitmentsTotal;

  /// Sum of the commitments already deducted this cycle.
  Money get paidFixedExpensesTotal => fixedExpenses
      .where((e) => e.status == FixedExpenseStatus.completed)
      .fold(const Money.zero(), (sum, e) => sum + e.amount);
}
