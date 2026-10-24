/// Arabic-language helpers: Gregorian month / weekday names and correct
/// number agreement for day counts (يوم، يومان، 3–10 أيام، 11+ يوماً).
abstract final class ArabicText {
  static const List<String> months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  /// Index follows [DateTime.weekday] − 1 (Monday = 0).
  static const List<String> weekdays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static String month(DateTime date) => months[date.month - 1];
  static String weekday(DateTime date) => weekdays[date.weekday - 1];

  /// `الخميس، 22 أكتوبر`
  static String weekdayAndDate(DateTime date) =>
      '${weekday(date)}، ${date.day} ${month(date)}';

  /// "after N days" form: `بعد يوم`, `بعد يومين`, `بعد 3 أيام`, `بعد 12 يوماً`.
  static String afterDays(int days) {
    return 'بعد ${_countedDays(days, accusative: true)}';
  }

  /// "N days remain" form: `باقي يوم واحد`, `باقي يومان`, `باقي 5 أيام`.
  static String remainingDays(int days) {
    return 'باقي ${_countedDays(days, accusative: false)}';
  }

  static String _countedDays(int n, {required bool accusative}) {
    if (n == 1) return accusative ? 'يوم' : 'يوم واحد';
    if (n == 2) return accusative ? 'يومين' : 'يومان';
    if (n >= 3 && n <= 10) return '$n أيام';
    return '$n يوماً';
  }
}
