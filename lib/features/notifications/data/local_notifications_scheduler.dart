import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rateby/features/notifications/domain/planned_reminder.dart';
import 'package:rateby/features/notifications/domain/reminder_scheduler.dart';
import 'package:timezone/timezone.dart' as tz;

/// [ReminderScheduler] backed by `flutter_local_notifications` (Android / iOS).
///
/// Each reminder is a one-shot notification at an absolute instant, so no
/// time-zone database is needed. Inexact alarms are used on purpose: they
/// need no "exact alarm" permission and may fire a few minutes late, which is
/// fine for a morning reminder.
class LocalNotificationsScheduler implements ReminderScheduler {
  LocalNotificationsScheduler([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initialised;

  Future<void> _ensureInitialised() => _initialised ??= _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );

  @override
  Future<bool> requestPermission() async {
    await _ensureInitialised();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    await _ensureInitialised();
    await _plugin.cancelAll();
    for (final reminder in reminders) {
      await _plugin.zonedSchedule(
        reminder.id,
        reminder.title,
        reminder.body,
        tz.TZDateTime.from(reminder.at, tz.UTC),
        _details(reminder.kind),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  NotificationDetails _details(ReminderKind kind) {
    final (id, name, description) = switch (kind) {
      ReminderKind.payout => (
          'payout_alerts',
          'مواعيد الصرف',
          'تنبيهات بمواعيد صرف الرواتب والدعم',
        ),
      ReminderKind.dailyLimit => (
          'daily_limit',
          'الحد اليومي',
          'تذكير صباحي بحدك اليومي للصرف',
        ),
    };
    return NotificationDetails(
      android: AndroidNotificationDetails(
        id,
        name,
        channelDescription: description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }
}
