import 'package:flutter/foundation.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/budget_health.dart';
import 'package:rateby/features/budget/domain/entities/daily_allowance.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/budget/domain/entities/salary_cycle.dart';

enum HomeGreeting { morning, evening }

/// Everything the Home screen renders — already derived, so widgets only
/// display values and never compute them.
@immutable
class HomeState {
  const HomeState({
    required this.userName,
    required this.today,
    required this.greeting,
    required this.allowance,
    required this.health,
    required this.salaryCycle,
    required this.fixedExpenses,
    required this.fixedExpensesPaidTotal,
    required this.fixedExpensesTotal,
  });

  final String userName;
  final DateTime today;
  final HomeGreeting greeting;
  final DailyAllowance allowance;
  final BudgetHealth health;
  final SalaryCycle salaryCycle;
  final List<FixedExpense> fixedExpenses;

  /// Commitments already deducted this cycle.
  final Money fixedExpensesPaidTotal;

  /// All monthly commitments ("… من أصل 3,450 ر.س").
  final Money fixedExpensesTotal;
}
