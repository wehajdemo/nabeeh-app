import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/providers/clock_provider.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/budget/domain/entities/salary_cycle.dart';
import 'package:rateby/features/budget/domain/services/daily_limit_calculator.dart';
import 'package:rateby/features/notifications/domain/reminder_planner.dart';
import 'package:rateby/features/notifications/domain/reminder_scheduler.dart';
import 'package:rateby/features/payments/application/payout_schedule_providers.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';

/// Platform scheduler. Overridden in `main()` with the real implementation.
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => const NoopReminderScheduler(),
);

/// Rebuilds the scheduled notifications from the current data.
class ReminderSync {
  ReminderSync(this._ref);

  final Ref _ref;
  Future<void>? _running;
  bool _again = false;

  /// Asks for the notification permission (call when the user turns an
  /// alert on, never at start-up).
  Future<bool> ensurePermission() =>
      _ref.read(reminderSchedulerProvider).requestPermission();

  /// Re-plans and reschedules everything. Calls made while a run is in
  /// progress are merged into one follow-up run. Never throws.
  Future<void> sync() {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    return _running = _loop().whenComplete(() => _running = null);
  }

  Future<void> _loop() async {
    do {
      _again = false;
      try {
        await _syncOnce();
      } on Object {
        // Notifications are best-effort; the next sync tries again.
      }
    } while (_again);
  }

  Future<void> _syncOnce() async {
    final scheduler = _ref.read(reminderSchedulerProvider);
    final profile = await _ref.read(profileProvider.future);
    if (profile == null) {
      await scheduler.replaceAll(const []);
      return;
    }
    final settings = await _ref.read(settingsProvider.future);
    final goals = await _ref.read(goalsProvider.future);
    final schedule = await _ref.read(payoutScheduleProvider.future);
    final now = _ref.read(clockProvider)();

    Money? dailyLimitOn(DateTime day) {
      final cycle = SalaryCycle.forPayDay(payDay: profile.payDay, today: day);
      return DailyLimitCalculator.calculate(
        netSalary: profile.netSalary,
        commitmentsTotal: profile.commitmentsTotal,
        monthlyGoalsTotal: goals.fold(
          const Money.zero(),
          (sum, g) => sum + g.effectiveMonthly,
        ),
        cycleLengthDays: cycle.lengthInDays,
      );
    }

    await scheduler.replaceAll(
      ReminderPlanner.plan(
        now: now,
        // Daily-limit alerts are a Plus feature; a lapsed subscription
        // silences them (the choice is kept for when it renews).
        settings: settings.copyWith(
          dailyLimitAlerts:
              settings.dailyLimitAlerts && _ref.read(isPlusProvider),
        ),
        programs: schedule.programs,
        dailyLimitOn: dailyLimitOn,
      ),
    );
  }
}

final reminderSyncProvider = Provider<ReminderSync>(ReminderSync.new);

/// Watch this once near the root: it re-syncs whenever the settings, the
/// profile, the goals or the payout schedule change.
final reminderAutoSyncProvider = Provider<void>((ref) {
  ref
    ..watch(settingsProvider)
    ..watch(profileProvider)
    ..watch(goalsProvider)
    ..watch(payoutScheduleProvider)
    ..watch(isPlusProvider);
  unawaited(ref.read(reminderSyncProvider).sync());
});
