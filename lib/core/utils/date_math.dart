/// Calendar-day arithmetic that ignores time-of-day and DST shifts.
abstract final class DateMath {
  /// Whole calendar days from [from] to [to] (negative if [to] is earlier).
  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  /// Strips the time portion.
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Number of days in the month containing [year]/[month].
  static int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
}
