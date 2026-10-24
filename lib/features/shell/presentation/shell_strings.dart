/// Copy for messages raised by the app shell.
abstract final class ShellStrings {
  static String goalsCredited(int paydays) => paydays == 1
      ? 'تمت إضافة استقطاع الراتب إلى أهدافك'
      : 'تمت إضافة استقطاع $paydays رواتب إلى أهدافك';
}
