import 'package:rateby/features/notifications/domain/planned_reminder.dart';

/// Delivers [PlannedReminder]s through the platform (local notifications).
abstract interface class ReminderScheduler {
  /// Asks the user for permission to show notifications. Returns whether it
  /// is granted. Safe to call repeatedly.
  Future<bool> requestPermission();

  /// Cancels everything scheduled earlier and schedules exactly [reminders].
  Future<void> replaceAll(List<PlannedReminder> reminders);
}

/// Used where notifications are unavailable (web, tests).
class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {}
}
