import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/providers/clock_provider.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/notifications/application/reminder_sync.dart';
import 'package:rateby/features/payments/application/payments_state.dart';
import 'package:rateby/features/payments/application/payout_schedule_providers.dart';
import 'package:rateby/features/payments/domain/payout_schedule_calculator.dart';

/// Currently selected filter tab (ephemeral UI state).
class PayoutFilterController extends Notifier<PayoutFilter> {
  @override
  PayoutFilter build() => PayoutFilter.all;

  void select(PayoutFilter filter) => state = filter;
}

final payoutFilterProvider =
    NotifierProvider<PayoutFilterController, PayoutFilter>(
  PayoutFilterController.new,
);

/// Evaluates every payout program for today and owns the alert toggles.
class PaymentsController extends AsyncNotifier<PaymentsState> {
  @override
  Future<PaymentsState> build() async {
    final schedule = await ref.watch(payoutScheduleProvider.future);
    final now = ref.watch(clockProvider)();
    final settings = await ref.watch(settingsProvider.future);

    final infos = PayoutScheduleCalculator.evaluateAll(schedule.programs, now);
    return PaymentsState(
      today: now,
      scheduleSource: schedule.source,
      scheduleUpdatedAt: schedule.updatedAt,
      items: [
        for (final info in infos)
          PayoutItem(
            info: info,
            alertEnabled:
                settings.enabledPayoutAlertIds.contains(info.program.id),
          ),
      ],
    );
  }

  /// Pull-to-refresh: downloads the latest schedule. Returns `false` when it
  /// could not be fetched (offline, not configured, invalid document).
  Future<bool> refreshSchedule() =>
      ref.read(payoutScheduleRepositoryProvider).refresh();

  /// Turns the reminder for one program on or off. Returns `false` only when
  /// it was turned on but the device does not allow notifications.
  Future<bool> toggleAlert(String programId) async {
    final repository = ref.read(settingsRepositoryProvider);
    final current = await ref.read(settingsProvider.future);
    final ids = {...current.enabledPayoutAlertIds};
    final turnedOn = ids.add(programId);
    if (!turnedOn) ids.remove(programId);
    await repository.saveSettings(current.copyWith(enabledPayoutAlertIds: ids));
    return !turnedOn || await ref.read(reminderSyncProvider).ensurePermission();
  }
}

final paymentsControllerProvider =
    AsyncNotifierProvider<PaymentsController, PaymentsState>(
  PaymentsController.new,
);
