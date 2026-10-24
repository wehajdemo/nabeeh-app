import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';

/// Goals plus the headline figures derived from them.
@immutable
class GoalsState {
  const GoalsState({
    required this.goals,
    required this.totalSaved,
    required this.totalTarget,
    required this.monthlyDeductions,
    required this.payDay,
  });

  factory GoalsState.fromGoals(List<SavingsGoal> goals, {required int payDay}) {
    Money sum(Money Function(SavingsGoal g) pick) =>
        goals.fold(const Money.zero(), (acc, g) => acc + pick(g));

    return GoalsState(
      goals: goals,
      totalSaved: sum((g) => g.saved),
      totalTarget: sum((g) => g.target),
      monthlyDeductions: sum((g) => g.effectiveMonthly),
      payDay: payDay,
    );
  }

  final List<SavingsGoal> goals;
  final Money totalSaved;
  final Money totalTarget;

  /// Sum of the automatic monthly contributions of every goal.
  final Money monthlyDeductions;

  /// Day of month the deductions are taken (the user's payday).
  final int payDay;

  bool get isEmpty => goals.isEmpty;
  int get activeCount => goals.where((g) => !g.isComplete).length;

  Money get remaining => (totalTarget - totalSaved).clampNonNegative();

  /// 0‥1 share of all targets already saved.
  double get progress => totalSaved.fractionOf(totalTarget);

  /// Whole percent, rounded down (never claims 100% early).
  int get achievementPercent => totalTarget.isPositive
      ? math.min(100, totalSaved.halalas * 100 ~/ totalTarget.halalas)
      : 0;
}
