import 'package:rateby/core/utils/date_math.dart';
import 'package:rateby/features/budget/domain/entities/salary_cycle.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';

typedef PaydayCredit = ({
  List<SavingsGoal> goals,
  DateTime lastCredited,
  int paydays,
});

/// Adds each goal's monthly contribution to its saved amount for every
/// payday that has passed since the last time it was credited.
abstract final class GoalPaydayCrediting {
  /// Safety cap if the app was not opened for years.
  static const int maxPaydays = 24;

  /// The most recent payday on or before [today] (payday itself counts).
  static DateTime latestPayday({required int payDay, required DateTime today}) {
    final tomorrow = _nextDay(today);
    return SalaryCycle.forPayDay(payDay: payDay, today: tomorrow).previousPayday;
  }

  static PaydayCredit credit({
    required List<SavingsGoal> goals,
    required DateTime lastCredited,
    required int payDay,
    required DateTime today,
  }) {
    final latest = latestPayday(payDay: payDay, today: today);
    var credited = DateMath.dateOnly(lastCredited);
    var current = goals;
    var count = 0;

    while (count < maxPaydays) {
      // First payday strictly after the last credited one.
      final next = SalaryCycle.forPayDay(
        payDay: payDay,
        today: _nextDay(credited),
      ).nextPayday;
      if (next.isAfter(latest)) break;
      current = [
        for (final g in current) g.copyWith(saved: g.saved + g.effectiveMonthly),
      ];
      credited = next;
      count++;
    }
    if (count == maxPaydays && credited.isBefore(latest)) credited = latest;

    return (goals: current, lastCredited: credited, paydays: count);
  }

  static DateTime _nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);
}
