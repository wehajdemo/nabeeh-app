import 'package:rateby/features/notifications/domain/planned_reminder.dart';
import 'package:rateby/features/notifications/domain/reminder_scheduler.dart';

/// Records what would have been scheduled.
class RecordingReminderScheduler implements ReminderScheduler {
  RecordingReminderScheduler({this.permission = true});

  bool permission;
  int permissionRequests = 0;
  int replaceCalls = 0;
  List<PlannedReminder> plan = const [];

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permission;
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    replaceCalls++;
    plan = reminders;
  }

  List<PlannedReminder> of(ReminderKind kind) =>
      [for (final r in plan) if (r.kind == kind) r];
}
