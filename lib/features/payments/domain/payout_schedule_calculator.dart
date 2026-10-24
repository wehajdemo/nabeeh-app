import 'dart:math' as math;

import 'package:rateby/core/utils/date_math.dart';
import 'package:rateby/features/payments/domain/payout_info.dart';
import 'package:rateby/features/payments/domain/payout_program.dart';

typedef _Occurrence = ({DateTime nominal, DateTime date});

/// Pure date rules for payout programs.
///
/// Weekend rule (Saudi banking week): a deposit falling on **Friday** moves
/// to **Thursday**; one falling on **Saturday** moves to **Sunday**.
abstract final class PayoutScheduleCalculator {
  /// A deposit counts as "recently paid" for this many days.
  static const int recentlyPaidDays = 14;

  /// Moves [date] off the weekend following the rule above.
  static DateTime applyWeekendRule(DateTime date) {
    return switch (date.weekday) {
      DateTime.friday => date.subtract(const Duration(days: 1)),
      DateTime.saturday => date.add(const Duration(days: 1)),
      _ => date,
    };
  }

  static PayoutInfo evaluate(PayoutProgram program, DateTime now) {
    final today = DateMath.dateOnly(now);
    return program.isWindow
        ? _evaluateWindow(program, today)
        : _evaluateFixed(program, today);
  }

  static List<PayoutInfo> evaluateAll(
    Iterable<PayoutProgram> programs,
    DateTime now,
  ) =>
      [for (final p in programs) evaluate(p, now)];

  // ── Fixed-day programs ────────────────────────────────────────────────

  /// The nominal and weekend-adjusted date of [day] in the given month
  /// (month overflow such as 0 or 13 is normalised by [DateTime]).
  static _Occurrence _occurrence(int year, int month, int day) {
    final first = DateTime(year, month);
    final lastDay = DateMath.daysInMonth(first.year, first.month);
    final nominal = DateTime(first.year, first.month, math.min(day, lastDay));
    final shifted = applyWeekendRule(nominal);
    return (
      nominal: nominal,
      date: DateTime(shifted.year, shifted.month, shifted.day),
    );
  }

  static PayoutInfo _evaluateFixed(PayoutProgram program, DateTime today) {
    final occurrences = [
      for (var offset = -1; offset <= 1; offset++)
        _occurrence(today.year, today.month + offset, program.dayOfMonth),
    ];
    // Today counts as "next" (it is arriving today), never as "last".
    final next = occurrences.firstWhere((o) => !o.date.isBefore(today));
    final last = occurrences.lastWhere((o) => o.date.isBefore(today));

    final sinceLast = DateMath.daysBetween(last.date, today);
    final span = DateMath.daysBetween(last.date, next.date);
    final isRecentlyPaid = sinceLast <= recentlyPaidDays && next.date != today;

    return PayoutInfo(
      program: program,
      status: isRecentlyPaid
          ? PayoutStatus.paid
          : program.certainty == PayoutCertainty.confirmed
              ? PayoutStatus.confirmed
              : PayoutStatus.expected,
      nextPayout: next.date,
      lastPayout: last.date,
      daysUntilNext: DateMath.daysBetween(today, next.date),
      cycleProgress: span <= 0 ? 0 : (sinceLast / span).clamp(0.0, 1.0).toDouble(),
      wasShiftedForWeekend: next.nominal != next.date,
    );
  }

  // ── Window programs (date varies by institution) ──────────────────────

  static DateTime _dayIn(DateTime today, int monthOffset, int day) {
    final first = DateTime(today.year, today.month + monthOffset);
    final lastDay = DateMath.daysInMonth(first.year, first.month);
    return DateTime(first.year, first.month, math.min(day, lastDay));
  }

  static PayoutInfo _evaluateWindow(PayoutProgram program, DateTime today) {
    final startDay = program.dayOfMonth;
    final endDay = program.windowEndDay!;

    // This month's window stays "current" until it has fully passed.
    final offset = today.isAfter(_dayIn(today, 0, endDay)) ? 1 : 0;
    final windowStart = _dayIn(today, offset, startDay);
    final windowEnd = _dayIn(today, offset, endDay);

    return PayoutInfo(
      program: program,
      status: PayoutStatus.expected,
      nextPayout: windowStart,
      windowEnd: windowEnd,
      daysUntilNext: math.max(0, DateMath.daysBetween(today, windowStart)),
      daysUntilWindowEnd: DateMath.daysBetween(today, windowEnd),
      cycleProgress: 0,
      wasShiftedForWeekend: false,
    );
  }
}
