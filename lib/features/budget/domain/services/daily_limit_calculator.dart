import 'package:rateby/core/money/money.dart';

/// Business rule: what may be spent per day in a salary cycle.
///
/// `(net salary − fixed commitments − monthly goal deductions) ÷ cycle days`,
/// rounded **down** to whole riyals so the limit is never optimistic.
abstract final class DailyLimitCalculator {
  static Money calculate({
    required Money netSalary,
    required Money commitmentsTotal,
    required Money monthlyGoalsTotal,
    required int cycleLengthDays,
  }) {
    if (cycleLengthDays <= 0) return const Money.zero();
    final free =
        (netSalary - commitmentsTotal - monthlyGoalsTotal).clampNonNegative();
    final wholeRiyalsPerDay = free.halalas ~/ (100 * cycleLengthDays);
    return Money.fromRiyals(wholeRiyalsPerDay);
  }
}
