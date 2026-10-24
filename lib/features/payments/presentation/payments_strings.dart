/// Copy for the Payments (payout dates) tab.
abstract final class PaymentsStrings {
  static const String bannerTitle = 'مواعيد الرواتب والدعم';
  static const String bannerBadge = 'جدول إرشادي';
  static String bannerUpdated(String date) => 'آخر تحديث $date';
  static const String bannerBody =
      'المواعيد مبنية على الجداول المعلنة في البنوك والجهات الحكومية بالمملكة، وقد يختلف الإيداع الفعلي بيوم أو يومين. تأكد من الجهة المختصة.';

  static String filterAll(int count) => 'الكل ($count)';
  static const String filterGovernment = 'الرواتب الحكومية';
  static const String filterSupport = 'برامج الدعم';
  static const String filterRetireesStudents = 'المتقاعدين والطلاب';

  static const String confirmed = 'مؤكد';
  static const String expected = 'متوقع';
  static const String paid = 'تم الصرف';

  static const String fixedDate = 'الموعد المحدد';
  static const String payoutDate = 'موعد الصرف';
  static const String expectedDate = 'الموعد المتوقع';
  static const String expectedWindow = 'النافذة المتوقعة';
  static const String countdown = 'العد التنازلي';
  static const String remainingTime = 'المدة المتبقية';
  static const String arrivesToday = 'اليوم';
  static const String daysLabel = 'أيام';
  static const String daysRemainingLabel = 'أيام متبقية';
  static const String dayRemainingLabel = 'يوم متبقٍ';
  static const String withinWindow = 'ضمن النافذة الآن';
  static const String lastDeposit = 'تاريخ الإيداع الأخير';
  static const String nextPayment = 'الدفعة القادمة';
  static const String weekendShifted = 'عُدّل بسبب عطلة نهاية الأسبوع';

  static const String alert = 'تنبيهي';
  static const String alertOn = 'مفعل للدفعة القادمة';

  static String dateRange(int from, int to, String month, int year) =>
      '$from - $to $month $year';
  static String dayRange(int from, int to) => '$from - $to';

  static const String weekendRuleTitle = 'قاعدة عطلة نهاية الأسبوع الرسمية';
  static const String weekendRuleBody =
      'وفقاً للأنظمة المالية المعتمدة، إذا صادف موعد الصرف يوم الجمعة يتم تقديم الإيداع ليوم الخميس، وإذا صادف يوم السبت يتم تأخير الإيداع إلى يوم الأحد.';

  static const String notificationsBlocked =
      'الإشعارات غير مسموحة على جهازك. فعّلها من إعدادات النظام لتصلك التنبيهات.';
  static const String refreshFailed = 'تعذّر تحديث المواعيد. تحقق من الاتصال.';

  static const String emptyFilter = 'لا توجد برامج ضمن هذا التصنيف';
}
