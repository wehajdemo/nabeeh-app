/// Copy for the first-run wizard.
abstract final class OnboardingStrings {
  static String stepOf(int step, int total) => 'خطوة $step من $total';
  static const String back = 'رجوع للخطوة السابقة';

  // Step 1
  static const String salaryBadge = 'البداية سهلة جداً';
  static const String salaryTitle = 'كم راتبك الشهري الصافي؟';
  static const String salarySubtitle =
      'المبلغ الفعلي الذي ينزل في حسابك البنكي بعد خصم التأمينات والتقاعد.';
  static const String salaryFieldLabel = 'الراتب الشهري المحول';
  static const String nextCommitmentsTitle =
      'الخطوة القادمة: الالتزامات والمصاريف الثابتة';
  static const String nextCommitmentsNote =
      'أقساط تمويل السيارة، تابي، فواتير الاتصالات';
  static const String nextPaydayTitle = 'الخطوة الأخيرة: يوم إيداع الراتب';
  static const String nextPaydayNote =
      'الافتراضي 27 من كل شهر لموظفي القطاع الحكومي';

  // Step 2
  static const String commitmentsBadge = 'المصاريف المستقطعة';
  static const String commitmentsTitle = 'ما هي التزاماتك ومصاريفك الثابتة؟';
  static const String commitmentsSubtitle =
      'المبالغ الشهرية التي تُستقطع حتماً من راتبك لتحديد ما يتبقى لك يومياً بدقة.';
  static const String commitmentsTotal = 'إجمالي الالتزامات الشهرية';
  static const String autoDeducted = 'تُخصم تلقائياً';
  static const String lastStepTitle = 'الخطوة الأخيرة: موعد إيداع الراتب';
  static String lastStepNote(int day) => 'الافتراضي $day من كل شهر';

  // Step 3
  static const String paydayBadge = 'الخطوة الأخيرة';
  static const String paydayTitle = 'متى موعد نزول راتبك الشهري؟';
  static const String paydaySubtitle =
      'حتى نحسب لك كم باقي يوم ومقدار ما يمكنك صرفه يومياً حتى الإيداع.';

  // Summary
  static const String summaryTitle = 'ملخص ميزانيتك الذكية';
  static const String summaryReady = 'جاهز للانطلاق';
  static const String summarySalary = 'صافي الراتب';
  static const String summaryCommitments = 'الالتزامات الثابتة';
  static const String summaryDaily = 'حد الصرف اليومي المتوقع';
  static const String perDay = 'ر.س / يوم';
  static String untilPayday(int days) => switch (days) {
        0 => 'المتبقي حتى نزول الراتب: ينزل اليوم',
        1 => 'المتبقي حتى نزول الراتب: يوم واحد',
        2 => 'المتبقي حتى نزول الراتب: يومان',
        <= 10 => 'المتبقي حتى نزول الراتب: $days أيام',
        _ => 'المتبقي حتى نزول الراتب: $days يوماً',
      };

  // Footer
  static const String privacyNote = 'بياناتك المالية مشفرة ومحفوظة على جهازك فقط';
  static const String continueNext = 'متابعة للخطوة التالية';
  static const String continueLast = 'متابعة للخطوة الأخيرة';
  static const String start = 'بدء استخدام نبيه الآن ✨';
  static const String saving = 'جارٍ الإعداد…';
  static const String saveFailed = 'تعذّر حفظ البيانات، حاول مرة أخرى';
}
