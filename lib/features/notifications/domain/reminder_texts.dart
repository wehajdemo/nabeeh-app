import 'package:rateby/core/constants/app_strings.dart';

/// Wording of the notifications.
abstract final class ReminderTexts {
  static const String payoutTitle = 'موعد صرف';
  static const String dailyTitle = 'حدك اليومي';

  static String payoutTomorrow(String program, {required bool expected}) =>
      expected
          ? 'غداً الموعد المتوقع لصرف $program'
          : 'غداً موعد صرف $program';

  static String payoutToday(String program, {required bool expected}) =>
      expected
          ? 'اليوم الموعد المتوقع لصرف $program'
          : 'اليوم موعد صرف $program';

  static String payoutWindowStarts(String program, int fromDay, int toDay) =>
      'بدأت اليوم نافذة صرف $program المتوقعة (من $fromDay إلى $toDay)';

  static String dailyLimit(String amount) =>
      'صباح الخير! يمكنك صرف $amount ${AppStrings.currencySymbol} اليوم دون تجاوز حدك.';

  static const String dailyLimitGeneric =
      'صباح الخير! افتح نبيه لتعرف حدك اليومي وما تبقى منه.';
}
