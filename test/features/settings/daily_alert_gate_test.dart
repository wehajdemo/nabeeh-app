import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/notifications/application/reminder_sync.dart';
import 'package:rateby/features/settings/application/settings_controller.dart';
import 'package:rateby/features/upgrade/domain/plus_gate.dart';

import '../../support/recording_scheduler.dart';
import '../../support/test_overrides.dart';

ProviderContainer make({required bool plus}) {
  final container = ProviderContainer(
    overrides: [
      fixedClock(),
      demoStore(),
      reminderSchedulerProvider.overrideWithValue(RecordingReminderScheduler()),
      if (plus) plusActive(),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('without Plus, daily-limit alerts cannot be turned on', () async {
    final container = make(plus: false);
    container.listen(settingsControllerProvider, (_, __) {});
    await container.read(settingsControllerProvider.future);

    await expectLater(
      container.read(settingsControllerProvider.notifier).setDailyLimitAlerts(true),
      throwsA(isA<PlusRequiredException>()),
    );
  });

  test('turning them off is always allowed', () async {
    final container = make(plus: false);
    container.listen(settingsControllerProvider, (_, __) {});
    await container.read(settingsControllerProvider.future);

    final ok = await container
        .read(settingsControllerProvider.notifier)
        .setDailyLimitAlerts(false);

    expect(ok, isTrue);
    final settings = await container.read(settingsProvider.future);
    expect(settings.dailyLimitAlerts, isFalse);
  });

  test('with Plus they turn on and ask for the notification permission',
      () async {
    final container = make(plus: true);
    container.listen(settingsControllerProvider, (_, __) {});
    await container.read(settingsControllerProvider.future);

    final ok = await container
        .read(settingsControllerProvider.notifier)
        .setDailyLimitAlerts(true);

    expect(ok, isTrue);
    final settings = await container.read(settingsProvider.future);
    expect(settings.dailyLimitAlerts, isTrue);
  });

  test('payout alerts stay free', () async {
    final container = make(plus: false);
    container.listen(settingsControllerProvider, (_, __) {});
    await container.read(settingsControllerProvider.future);

    final ok = await container
        .read(settingsControllerProvider.notifier)
        .setOfficialPayoutAlerts(true);

    expect(ok, isTrue);
  });
}
