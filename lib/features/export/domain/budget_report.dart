import 'package:flutter/foundation.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/utils/date_math.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/budget/domain/entities/expense.dart';
import 'package:rateby/features/budget/domain/entities/salary_cycle.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';
import 'package:rateby/features/budget/domain/services/daily_limit_calculator.dart';

@immutable
class ReportCommitment {
  const ReportCommitment({required this.title, required this.amount});

  final String title;
  final Money amount;
}

@immutable
class ReportGoal {
  const ReportGoal({
    required this.title,
    required this.target,
    required this.saved,
    required this.monthly,
    required this.percent,
  });

  final String title;
  final Money target;
  final Money saved;

  /// What is set aside each payday (nothing once complete).
  final Money monthly;
  final int percent;
}

/// One calendar day of spending.
@immutable
class ReportDay {
  const ReportDay({required this.date, required this.total, required this.count});

  final DateTime date;
  final Money total;
  final int count;
}

/// Everything the PDF / CSV exports show, computed once.
@immutable
class BudgetReport {
  const BudgetReport({
    required this.generatedAt,
    required this.netSalary,
    required this.payDay,
    required this.cycleStart,
    required this.cycleEnd,
    required this.commitments,
    required this.commitmentsTotal,
    required this.goals,
    required this.goalsMonthlyTotal,
    required this.dailyLimit,
    required this.spentInCycle,
    required this.spentToday,
    required this.days,
    required this.expenses,
  });

  final DateTime generatedAt;
  final Money netSalary;
  final int payDay;

  /// First day of the current salary cycle (the last payday).
  final DateTime cycleStart;

  /// The next payday (the cycle ends the day before).
  final DateTime cycleEnd;

  final List<ReportCommitment> commitments;
  final Money commitmentsTotal;
  final List<ReportGoal> goals;
  final Money goalsMonthlyTotal;
  final Money dailyLimit;
  final Money spentInCycle;
  final Money spentToday;

  /// Spending per day in this cycle, newest first.
  final List<ReportDay> days;

  /// Every expense in this cycle, oldest first.
  final List<Expense> expenses;

  /// What is left of the salary after commitments and goals.
  Money get freeToSpend =>
      (netSalary - commitmentsTotal - goalsMonthlyTotal).clampNonNegative();

  Money get remainingInCycle => (freeToSpend - spentInCycle).clampNonNegative();
}

abstract final class BudgetReportBuilder {
  static BudgetReport build({
    required BudgetProfile profile,
    required List<SavingsGoal> goals,
    required List<Expense> expenses,
    required DateTime now,
  }) {
    final cycle = SalaryCycle.forPayDay(
      payDay: profile.payDay,
      today: DateMath.dateOnly(now),
    );

    final inCycle = [
      for (final e in expenses)
        if (!DateMath.dateOnly(e.createdAt).isBefore(cycle.previousPayday) &&
            DateMath.dateOnly(e.createdAt).isBefore(cycle.nextPayday))
          e,
    ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    Money sum(Iterable<Money> values) =>
        values.fold(const Money.zero(), (a, b) => a + b);

    final byDay = <DateTime, List<Expense>>{};
    for (final e in inCycle) {
      byDay.putIfAbsent(DateMath.dateOnly(e.createdAt), () => []).add(e);
    }
    final days = [
      for (final entry in byDay.entries)
        ReportDay(
          date: entry.key,
          total: sum(entry.value.map((e) => e.amount)),
          count: entry.value.length,
        ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final goalsMonthly = sum(goals.map((g) => g.effectiveMonthly));
    final today = DateMath.dateOnly(now);

    return BudgetReport(
      generatedAt: now,
      netSalary: profile.netSalary,
      payDay: profile.payDay,
      cycleStart: cycle.previousPayday,
      cycleEnd: cycle.nextPayday,
      commitments: [
        for (final c in profile.commitments)
          ReportCommitment(title: c.title, amount: c.amount),
      ],
      commitmentsTotal: profile.commitmentsTotal,
      goals: [
        for (final g in goals)
          ReportGoal(
            title: g.title,
            target: g.target,
            saved: g.saved,
            monthly: g.effectiveMonthly,
            percent: g.percent,
          ),
      ],
      goalsMonthlyTotal: goalsMonthly,
      dailyLimit: DailyLimitCalculator.calculate(
        netSalary: profile.netSalary,
        commitmentsTotal: profile.commitmentsTotal,
        monthlyGoalsTotal: goalsMonthly,
        cycleLengthDays: cycle.lengthInDays,
      ),
      spentInCycle: sum(inCycle.map((e) => e.amount)),
      spentToday: sum(
        inCycle
            .where((e) => DateMath.dateOnly(e.createdAt) == today)
            .map((e) => e.amount),
      ),
      days: days,
      expenses: inCycle,
    );
  }
}
