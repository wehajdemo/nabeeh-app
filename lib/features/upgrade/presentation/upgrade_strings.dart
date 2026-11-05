import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';

/// Copy for the Upgrade (نبيه بلس) tab.
abstract final class UpgradeStrings {
  static const String heroBadge = 'الخطة الذهبية المتكاملة';
  static const String heroTitle = 'نبيه بلس';
  static const String heroBody =
      'تحكم كامل وتجربة مالية هادئة بدون أي إعلانات، مصممة لأصحاب الطموح';

  static String trialDays(int days) =>
      days == 1 ? 'يوم' : days == 2 ? 'يومان' : '$days أيام';
  static const String statTrial = 'تجربة مجانية';
  static const String statAdsValue = '0 إعلانات';
  static const String statAdsLabel = 'تركيز مطلق';
  static const String statCancelValue = '100%';
  static const String statCancelLabel = 'إلغاء فوري';

  static const String plansTitle = 'اختر الخطة المناسبة لك';
  static const String plansHint = 'تجربة بلا مخاطر';
  static String bestValue(int percent) => 'الأكثر توفيراً وفر $percent%';
  static const String yearlyTitle = 'الاشتراك السنوي';
  static String yearlyNote(String price) =>
      'تدفع سنوياً $price ${AppStrings.currencySymbol} فقط بعد انتهاء التجربة';
  static const String monthlyTitle = 'الاشتراك الشهري';
  static const String monthlyNote = 'مرونة الإلغاء في أي وقت بدون التزامات';
  static const String perMonth = '${AppStrings.currencySymbol} / شهر';
  static const String monthlyRenewal = 'تجديد شهري';
  static String strikePrice(String price) =>
      '$price ${AppStrings.currencySymbol}';

  static const String benefitsTitle = 'ماذا ستحصل مع نبيه بلس؟';
  static const String benefitNoAdsTitle = 'إزالة جميع الإعلانات نهائياً';
  static const String benefitNoAdsBody =
      'تصفح فوري وسلس لواجهتك المالية بدون أي مقاطعات مشتتة لانتباهك.';
  static const String benefitAlertsTitle = 'تنبيهات حية وذكية لحد الصرف';
  static const String benefitAlertsBody =
      'إشعارات استباقية عندما تقترب من كسر حد الصرف اليومي لحماية راتبك حتى آخر الشهر.';
  static const String benefitGoalsTitle = 'أهداف ادخار غير محدودة وتصدير تقارير';
  static const String benefitGoalsBody =
      'أنشئ صناديق ادخار بعدد لا نهائي، وقم بتصدير كشوفاتك الشهرية بصيغة PDF أنيقة.';
  static const String benefitSupportTitle = 'دعم بأولوية وتجربة التحديثات أولاً';
  static const String benefitSupportBody =
      'أولوية في الرد على استفساراتك عبر البريد، وأولوية حصرية لتجربة التحديثات القادمة.';

  static String subscribe(int trialDays) =>
      'اشترك الآن واستمتع بـ ${UpgradeStrings.trialDays(trialDays)} مجاناً';
  static String trialNote(int trialDays) =>
      'لن يتم الخصم إلا بعد انقضاء الـ $trialDays أيام. إلغاء سهل بنقرة واحدة.';
  static const String restore = 'استعادة المشتريات السابقة';
  static const String terms = 'شروط الاستخدام';
  static const String privacy = 'سياسة الخصوصية';
  static const String support = 'الدعم والمساعدة';
  static const String renewalNote =
      'يتجدد الاشتراك تلقائياً بنفس السعر في نهاية كل فترة ما لم تلغه قبل انتهائها بـ 24 ساعة على الأقل، ويُخصم المبلغ من حسابك في المتجر (Apple أو Google Play). تدير اشتراكك وتلغيه من إعدادات المتجر.';
  static const String vatNote =
      'الأسعار تشمل ضريبة القيمة المضافة المعمول بها في المملكة العربية السعودية.';

  static const String billingUnavailable =
      'الاشتراك غير متاح بعد في هذه النسخة';
  static const String purchaseFailed = 'تعذّر إتمام العملية، حاول مرة أخرى';
  static const String purchaseDone = 'تم تفعيل نبيه بلس';
  static const String purchasePending =
      'عملية الدفع قيد المعالجة. سيتفعّل نبيه بلس تلقائياً عند اكتمالها';
  static const String nothingToRestore =
      'لم نجد اشتراكاً نشطاً لهذا الحساب';
  static const String linkFailed = 'تعذّر فتح الرابط';

  static const String activeTitle = 'اشتراكك في نبيه بلس نشط';
  static String activePlan(PlusPlanType? plan) => switch (plan) {
        PlusPlanType.yearly => 'الخطة: $yearlyTitle',
        PlusPlanType.monthly => 'الخطة: $monthlyTitle',
        null => 'شكراً لدعمك نبيه',
      };
  static String activeUntil(String date) => 'الفترة المدفوعة سارية حتى $date';
  static const String manageSubscription = 'إدارة الاشتراك';
}
