import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/app_settings.dart';
import 'package:rateby/features/notifications/domain/planned_reminder.dart';
import 'package:rateby/features/notifications/domain/reminder_planner.dart';
import 'package:rateby/features/payments/domain/payout_catalog.dart';

import '../../support/test_overrides.dart';

List<PlannedReminder> plan({
  DateTime? now,
  AppSettings settings = const AppSettings(
    enabledPayoutAlertIds: {'gov-salaries'},
  ),
  Money? Function(DateTime)? limit,
}) =>
    ReminderPlanner.plan(
      now: now ?? testNow,
      settings: settings,
      programs: PayoutCatalog.programs,
      dailyLimitOn: limit ?? (_) => Money.fromRiyals(221),
    );

List<PlannedReminder> only(List<PlannedReminder> all, ReminderKind kind) =>
    [for (final r in all) if (r.kind == kind) r];

void main() {
  test('payout alerts: the evening before and the morning of, three months',
      () {
    final payouts = only(plan(), ReminderKind.payout);

    expect(payouts.map((r) => r.at), [
      DateTime(2026, 10, 26, 18),
      DateTime(2026, 10, 27, 9),
      DateTime(2026, 11, 25, 18), // 27 Nov is a Friday → paid Thu 26 Nov
      DateTime(2026, 11, 26, 9),
      DateTime(2026, 12, 26, 18),
      DateTime(2026, 12, 27, 9),
    ]);
    expect(payouts[0].body, 'غداً موعد صرف رواتب القطاع الحكومي');
    expect(payouts[1].body, 'اليوم موعد صرف رواتب القطاع الحكومي');
  });

  test('"expected" programs say so', () {
    final payouts = only(
      plan(
        settings: const AppSettings(enabledPayoutAlertIds: {'retirees'}),
      ),
      ReminderKind.payout,
    );
    // 1 Nov 2026 is a Sunday.
    expect(payouts.first.at, DateTime(2026, 10, 31, 18));
    expect(payouts.first.body, contains('المتوقع'));
    expect(payouts[1].at, DateTime(2026, 11, 1, 9));
  });

  test('window programs get one reminder when the window opens', () {
    final payouts = only(
      plan(
        settings: const AppSettings(
          enabledPayoutAlertIds: {'student-stipends'},
        ),
      ),
      ReminderKind.payout,
    );
    expect(payouts.map((r) => r.at), [
      DateTime(2026, 10, 25, 9),
      DateTime(2026, 11, 25, 9),
      DateTime(2026, 12, 25, 9),
    ]);
    expect(payouts.first.body, contains('من 25 إلى 28'));
  });

  test('only reminders in the future are kept', () {
    final payouts = only(
      plan(now: DateTime(2026, 10, 27, 10)),
      ReminderKind.payout,
    );
    expect(payouts.first.at, DateTime(2026, 11, 25, 18));
  });

  test('daily limit reminders: 9:00 for the next days, today only if early',
      () {
    final evening = only(plan(), ReminderKind.dailyLimit);
    expect(evening, hasLength(6));
    expect(evening.first.at, DateTime(2026, 10, 23, 9));
    expect(evening.last.at, DateTime(2026, 10, 28, 9));

    final early = only(plan(now: DateTime(2026, 10, 22, 7)), ReminderKind.dailyLimit);
    expect(early, hasLength(ReminderPlanner.dailyHorizonDays));
    expect(early.first.at, DateTime(2026, 10, 22, 9));
  });

  test('the daily reminder shows that day\'s limit, or generic text', () {
    final withLimit = only(
      plan(limit: (day) => Money.fromRiyals(day.day == 24 ? 300 : 221)),
      ReminderKind.dailyLimit,
    );
    expect(withLimit.firstWhere((r) => r.at.day == 24).body, contains('300'));
    expect(withLimit.firstWhere((r) => r.at.day == 25).body, contains('221'));

    final generic = only(plan(limit: (_) => null), ReminderKind.dailyLimit);
    expect(generic.first.body, isNot(contains('221')));
  });

  test('switches turn each kind off', () {
    expect(
      only(
        plan(
          settings: const AppSettings(
            officialPayoutAlerts: false,
            enabledPayoutAlertIds: {'gov-salaries'},
          ),
        ),
        ReminderKind.payout,
      ),
      isEmpty,
    );
    expect(
      only(
        plan(
          settings: const AppSettings(
            dailyLimitAlerts: false,
            enabledPayoutAlertIds: {'gov-salaries'},
          ),
        ),
        ReminderKind.dailyLimit,
      ),
      isEmpty,
    );
    expect(
      plan(
        settings: const AppSettings(
          dailyLimitAlerts: false,
          officialPayoutAlerts: false,
        ),
      ),
      isEmpty,
    );
  });

  test('programs the user did not pick, or that no longer exist, are ignored',
      () {
    final payouts = only(
      plan(
        settings: const AppSettings(enabledPayoutAlertIds: {'ghost'}),
      ),
      ReminderKind.payout,
    );
    expect(payouts, isEmpty);
  });

  test('ids are 1..n in chronological order and the plan is deterministic',
      () {
    final a = plan();
    final b = plan();
    expect(a, b);
    expect(a.map((r) => r.id), [for (var i = 1; i <= a.length; i++) i]);
    for (var i = 1; i < a.length; i++) {
      expect(a[i].at.isBefore(a[i - 1].at), isFalse);
    }
  });
}
