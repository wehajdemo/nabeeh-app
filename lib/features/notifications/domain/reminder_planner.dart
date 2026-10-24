import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/utils/date_math.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/features/budget/domain/entities/app_settings.dart';
import 'package:rateby/features/notifications/domain/planned_reminder.dart';
import 'package:rateby/features/notifications/domain/reminder_texts.dart';
import 'package:rateby/features/payments/domain/payout_program.dart';
import 'package:rateby/features/payments/domain/payout_schedule_calculator.dart';

/// Decides which notifications should exist, as a pure function of the
/// settings, the payout schedule and "now". The result replaces whatever was
/// scheduled before, so changing a setting can never leave a stale reminder.
abstract final class ReminderPlanner {
  /// Hour of day (24h) for morning / payout-day reminders.
  static const int morningHour = 9;

  /// Hour for the evening-before payout reminder.
  static const int eveningHour = 18;

  /// How many days of daily-limit reminders are queued ahead.
  static const int dailyHorizonDays = 7;

  /// How many upcoming payouts are queued per program, so reminders keep
  /// arriving even if the app is not opened for a while.
  static const int payoutsPerProgram = 3;

  /// [dailyLimitOn] returns the limit for a given day (`null` → generic text).
  static List<PlannedReminder> plan({
    required DateTime now,
    required AppSettings settings,
    required List<PayoutProgram> programs,
    required Money? Function(DateTime day) dailyLimitOn,
  }) {
    final drafts = <PlannedReminder>[
      if (settings.officialPayoutAlerts)
        for (final program in programs)
          if (settings.enabledPayoutAlertIds.contains(program.id))
            ..._payoutReminders(program, now),
      if (settings.dailyLimitAlerts) ..._dailyReminders(now, dailyLimitOn),
    ]
        .where((r) => r.at.isAfter(now))
        .toList()
      ..sort(_byTimeThenKind);

    return [
      for (var i = 0; i < drafts.length; i++) drafts[i].withId(i + 1),
    ];
  }

  /// Deterministic order (payouts before the daily reminder at the same time).
  static int _byTimeThenKind(PlannedReminder a, PlannedReminder b) {
    final byTime = a.at.compareTo(b.at);
    if (byTime != 0) return byTime;
    final byKind = a.kind.index.compareTo(b.kind.index);
    return byKind != 0 ? byKind : a.body.compareTo(b.body);
  }

  static DateTime _at(DateTime day, int hour) =>
      DateTime(day.year, day.month, day.day, hour);

  static DateTime _nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);

  static List<PlannedReminder> _payoutReminders(
    PayoutProgram program,
    DateTime now,
  ) {
    final expected = program.certainty == PayoutCertainty.expected;
    final out = <PlannedReminder>[];
    var cursor = now;

    for (var i = 0; i < payoutsPerProgram; i++) {
      final info = PayoutScheduleCalculator.evaluate(program, cursor);
      final date = DateMath.dateOnly(info.nextPayout);

      if (info.isWindow) {
        out.add(
          PlannedReminder(
            id: 0,
            kind: ReminderKind.payout,
            at: _at(date, morningHour),
            title: ReminderTexts.payoutTitle,
            body: ReminderTexts.payoutWindowStarts(
              program.title,
              program.dayOfMonth,
              program.windowEndDay!,
            ),
          ),
        );
        cursor = _nextDay(info.windowEnd!);
      } else {
        out
          ..add(
            PlannedReminder(
              id: 0,
              kind: ReminderKind.payout,
              at: _at(DateTime(date.year, date.month, date.day - 1), eveningHour),
              title: ReminderTexts.payoutTitle,
              body: ReminderTexts.payoutTomorrow(program.title, expected: expected),
            ),
          )
          ..add(
            PlannedReminder(
              id: 0,
              kind: ReminderKind.payout,
              at: _at(date, morningHour),
              title: ReminderTexts.payoutTitle,
              body: ReminderTexts.payoutToday(program.title, expected: expected),
            ),
          );
        cursor = _nextDay(date);
      }
    }
    return out;
  }

  static List<PlannedReminder> _dailyReminders(
    DateTime now,
    Money? Function(DateTime day) dailyLimitOn,
  ) {
    final today = DateMath.dateOnly(now);
    return [
      for (var i = 0; i < dailyHorizonDays; i++)
        _daily(DateTime(today.year, today.month, today.day + i), dailyLimitOn),
    ];
  }

  static PlannedReminder _daily(
    DateTime day,
    Money? Function(DateTime day) dailyLimitOn,
  ) {
    final limit = dailyLimitOn(day);
    return PlannedReminder(
      id: 0,
      kind: ReminderKind.dailyLimit,
      at: _at(day, morningHour),
      title: ReminderTexts.dailyTitle,
      body: limit != null && limit.isPositive
          ? ReminderTexts.dailyLimit(MoneyFormatter.format(limit))
          : ReminderTexts.dailyLimitGeneric,
    );
  }
}
