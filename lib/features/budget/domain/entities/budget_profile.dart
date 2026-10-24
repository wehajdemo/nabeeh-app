import 'package:flutter/foundation.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';

/// The user's financial set-up collected during onboarding.
@immutable
class BudgetProfile {
  const BudgetProfile({
    required this.netSalary,
    required this.payDay,
    this.commitments = const [],
  });

  /// Placeholder used before onboarding finishes.
  static const BudgetProfile empty = BudgetProfile(
    netSalary: Money.zero(),
    payDay: defaultPayDay,
  );

  static const int defaultPayDay = 27;

  final Money netSalary;

  /// Day of month (1–31) the salary is deposited.
  final int payDay;
  final List<FixedExpense> commitments;

  Money get commitmentsTotal =>
      commitments.fold(const Money.zero(), (sum, c) => sum + c.amount);

  BudgetProfile copyWith({
    Money? netSalary,
    int? payDay,
    List<FixedExpense>? commitments,
  }) {
    return BudgetProfile(
      netSalary: netSalary ?? this.netSalary,
      payDay: payDay ?? this.payDay,
      commitments: commitments ?? this.commitments,
    );
  }
}

/// User input for a new fixed commitment.
@immutable
class CommitmentDraft {
  const CommitmentDraft({
    required this.title,
    required this.amount,
    required this.category,
  });

  final String title;
  final Money amount;
  final FixedExpenseCategory category;
}
