import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/features/notifications/application/reminder_sync.dart';
import 'package:rateby/features/notifications/domain/planned_reminder.dart';
import 'package:rateby/features/payments/application/payments_controller.dart';

import '../../support/recording_scheduler.dart';
import '../../support/test_overrides.dart';

ProviderContainer makeContainer(
  RecordingReminderScheduler scheduler, {
  bool demo = true,
  bool plus = true,
}) {
  final container = ProviderContainer(
    overrides: [
      fixedClock(),
      if (demo) demoStore() else emptyStore(),
      reminderSchedulerProvider.overrideWithValue(scheduler),
      if (plus) plusActive(),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('schedules the morning reminders with each day\'s own limit', () async {
    final scheduler = RecordingReminderScheduler();
    final container = makeContainer(scheduler);

    await container.read(reminderSyncProvider).sync();

    final daily = scheduler.of(ReminderKind.dailyLimit);
    expect(daily, hasLength(6));
    // Cycle 27 Sep → 27 Oct is 30 days: (12,000 − 3,450 − 1,900) ÷ 30 = 221.
    expect(daily.first.body, contains('221'));
    // From 28 Oct the cycle is 31 days: 6,650 ÷ 31 = 214.
    expect(daily.last.at, DateTime(2026, 10, 28, 9));
    expect(daily.last.body, contains('214'));
  });

  test('without Plus the daily-limit reminders are not scheduled', () async {
    final scheduler = RecordingReminderScheduler();
    final container = makeContainer(scheduler, plus: false);

    await container.read(reminderSyncProvider).sync();

    expect(scheduler.of(ReminderKind.dailyLimit), isEmpty);
  });

  test('before onboarding nothing is scheduled (and old reminders are cleared)',
      () async {
    final scheduler = RecordingReminderScheduler();
    final container = makeContainer(scheduler, demo: false);

    await container.read(reminderSyncProvider).sync();

    expect(scheduler.replaceCalls, 1);
    expect(scheduler.plan, isEmpty);
  });

  test('turning a payout alert on reschedules automatically', () async {
    final scheduler = RecordingReminderScheduler();
    final container = makeContainer(scheduler);
    container.listen(reminderAutoSyncProvider, (_, __) {});
    container.listen(paymentsControllerProvider, (_, __) {});
    await container.read(paymentsControllerProvider.future);
    await settle();
    expect(scheduler.of(ReminderKind.payout), isEmpty);

    await container
        .read(paymentsControllerProvider.notifier)
        .toggleAlert('gov-salaries');
    await settle();
    await settle();

    expect(scheduler.of(ReminderKind.payout), hasLength(6));

    await container
        .read(paymentsControllerProvider.notifier)
        .toggleAlert('gov-salaries');
    await settle();
    await settle();

    expect(scheduler.of(ReminderKind.payout), isEmpty);
  });

  test('permission is requested when an alert is turned on, not when off',
      () async {
    final scheduler = RecordingReminderScheduler();
    final container = makeContainer(scheduler);
    container.listen(paymentsControllerProvider, (_, __) {});
    await container.read(paymentsControllerProvider.future);
    final controller = container.read(paymentsControllerProvider.notifier);

    expect(await controller.toggleAlert('gov-salaries'), isTrue);
    expect(scheduler.permissionRequests, 1);

    await settle();
    expect(await controller.toggleAlert('gov-salaries'), isTrue);
    expect(scheduler.permissionRequests, 1, reason: 'turning off asks nothing');
  });

  test('a blocked permission is reported to the caller', () async {
    final scheduler = RecordingReminderScheduler(permission: false);
    final container = makeContainer(scheduler);
    container.listen(paymentsControllerProvider, (_, __) {});
    await container.read(paymentsControllerProvider.future);

    final ok = await container
        .read(paymentsControllerProvider.notifier)
        .toggleAlert('gov-salaries');

    expect(ok, isFalse);
  });

  test('overlapping syncs are merged and never throw', () async {
    final scheduler = RecordingReminderScheduler();
    final container = makeContainer(scheduler);
    final sync = container.read(reminderSyncProvider);

    await Future.wait([sync.sync(), sync.sync(), sync.sync()]);

    expect(scheduler.replaceCalls, lessThanOrEqualTo(2));
    expect(scheduler.replaceCalls, greaterThanOrEqualTo(1));
  });
}
