import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:rateby/core/utils/date_math.dart';

/// The span between two paydays, e.g. 27 Sep → 27 Oct.
@immutable
class SalaryCycle {
  const SalaryCycle._({
    required this.payDay,
    required this.today,
    required this.previousPayday,
    required this.nextPayday,
  });

  /// Builds the cycle that contains [today] for a salary deposited on the
  /// [payDay]-th of each month (clamped for short months, so day 31 pays on
  /// the 28th/29th in February).
  factory SalaryCycle.forPayDay({
    required int payDay,
    required DateTime today,
  }) {
    final day = DateMath.dateOnly(today);

    DateTime paydayIn(int year, int month) {
      // DateTime normalizes month 0 / 13, so month ± 1 is safe.
      final normalized = DateTime(year, month);
      final lastDay = DateMath.daysInMonth(normalized.year, normalized.month);
      return DateTime(
        normalized.year,
        normalized.month,
        math.min(payDay, lastDay),
      );
    }

    final thisMonthPayday = paydayIn(day.year, day.month);
    final DateTime next;
    final DateTime previous;
    if (day.isAfter(thisMonthPayday)) {
      next = paydayIn(day.year, day.month + 1);
      previous = thisMonthPayday;
    } else {
      next = thisMonthPayday;
      previous = paydayIn(day.year, day.month - 1);
    }

    return SalaryCycle._(
      payDay: payDay,
      today: day,
      previousPayday: previous,
      nextPayday: next,
    );
  }

  final int payDay;
  final DateTime today;
  final DateTime previousPayday;
  final DateTime nextPayday;

  /// 0 on payday itself.
  int get daysUntilPayday => DateMath.daysBetween(today, nextPayday);

  bool get isPaydayToday => daysUntilPayday == 0;

  int get lengthInDays => DateMath.daysBetween(previousPayday, nextPayday);

  /// 0‥1 — how far through the cycle we are.
  double get progress {
    final length = lengthInDays;
    if (length <= 0) return 0;
    final elapsed = DateMath.daysBetween(previousPayday, today);
    return (elapsed / length).clamp(0.0, 1.0).toDouble();
  }

  @override
  bool operator ==(Object other) =>
      other is SalaryCycle &&
      other.payDay == payDay &&
      other.today == today &&
      other.nextPayday == nextPayday;

  @override
  int get hashCode => Object.hash(payDay, today, nextPayday);
}
