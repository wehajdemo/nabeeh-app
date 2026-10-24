import 'package:rateby/core/constants/app_strings.dart';

/// Copy for the Settings tab.
abstract final class SettingsStrings {
  static const String title = 'الإعدادات المالية';
  static const String subtitle = 'خصص مصادرك المالية وتنبيهات ميزانيتك الشهرية';
  static const String saved = 'تم الحفظ بنجاح';

  // Basics
  static const String basicsSection = 'البيانات المالية الأساسية';
  static const String salaryTitle = 'الراتب الشهري الصافي';
  static const String salarySubtitle = 'المبلغ المحول لحسابك البنكي';
  static const String commitmentsTitle = 'المصاريف والالتزامات الثابتة';
  static const String commitmentsNone = 'لم تضف أي التزامات بعد';
  static const String paydayTitle = 'يوم نزول الراتب';
  static const String paydayGovernmentNote = 'موافق لموعد رواتب الموظفين الحكومية';
  static const String paydayCustomNote = 'حسب جدول رواتبك';
  static String paydayValue(int day) => '$day من كل شهر';
  static String commitmentsSummary(List<String> titles) => titles.join('، ');

  // Commitments sheet
  static const String commitmentsSheetTitle = 'المصاريف والالتزامات الثابتة';
  static const String commitmentsSheetSubtitle = 'تُخصم من راتبك قبل حساب الحد اليومي';
  static const String commitmentsEmpty = 'لا توجد التزامات مسجلة';

  // Preferences
  static const String preferencesSection = 'التفضيلات والتنبيهات';
  static const String dailyAlertTitle = 'التنبيه اليومي لحد الصرف';
  static const String dailyAlertSubtitle = 'تذكير صباحي بحد الإنفاق المتاح لليوم';
  static const String payoutAlertTitle = 'تنبيهات مواعيد الصرف الرسمية';
  static const String payoutAlertSubtitle = 'إيداع حساب المواطن وموعد الراتب';
  static const String appearanceTitle = 'المظهر';
  static const String appearanceSubtitle = 'فاتح أو داكن لراحة العينين، أو حسب إعداد هاتفك';
  static const String appearanceSheetSubtitle = 'يتغير المظهر فوراً ويُحفظ على جهازك';
  static const String appearanceSystem = 'حسب الهاتف';
  static const String appearanceSystemHint = 'يتبع وضع الإضاءة في إعدادات جهازك';
  static const String appearanceLight = 'فاتح';
  static const String appearanceDark = 'داكن (ليلي)';

  // Account
  static const String accountSection = 'الحساب والترقية';
  static const String plusBadge = 'باقة نبيه بلس';
  static const String plusTitle = 'ترقية غير محدودة وتجربة بدون إعلانات';
  static const String plusBody = 'تحليلات متقدمة لتوفير الفائض وتجربة هادئة بدون إعلانات';
  static String plusCta(String price) =>
      'الترقية الآن بـ $price ${AppStrings.currencySymbol} / شهرياً';

  static const String exportTitle = 'تصدير البيانات المالية';
  static const String exportSubtitle = 'تحميل كشف الميزانية بصيغة PDF أو Excel';
  static const String privacyTitle = 'سياسة الخصوصية والأمان';
  static const String termsTitle = 'شروط الاستخدام';
  static const String termsSubtitle = 'الاشتراك، مواعيد الصرف، حدود المسؤولية';
  static const String supportTitle = 'الدعم والمساعدة';
  static const String supportSubtitle = 'أسئلة شائعة وتواصل معنا';
  static const String privacySubtitle = 'بياناتك المالية تبقى محفوظة على جهازك';
  static const String aboutTitle = 'عن تطبيق نبيه';
  static const String aboutSubtitle = 'النسخة الرسمية';
  static String versionTag(String v) => 'v$v';

  // Reset
  static const String resetTitle = 'إعادة ضبط الحساب والبيانات المالية';
  static const String resetBody =
      'سيؤدي هذا الإجراء إلى حذف جميع سجلات المصاريف الشهرية ومبالغ التوفير وتصفير الحساب تماماً.';
  static const String resetButton = 'تصفير الحساب والبدء من جديد';
  static const String resetConfirmTitle = 'هل أنت متأكد؟';
  static const String resetConfirmBody =
      'سيتم حذف راتبك والتزاماتك وأهدافك وكل المصاريف المسجلة، ولا يمكن التراجع عن هذا الإجراء.';
  static const String resetConfirm = 'نعم، احذف كل شيء';
  static const String cancel = 'إلغاء';

  static const String notificationsBlocked =
      'الإشعارات غير مسموحة على جهازك. فعّلها من إعدادات النظام لتصلك التنبيهات.';
  static const String adChoicesTitle = 'خيارات الإعلانات';
  static const String adChoicesSubtitle = 'غيّر موافقتك على الإعلانات المخصّصة';
  static const String dailyAlertSubtitleLocked =
      'من مزايا نبيه بلس — اشترك لتفعيلها';
  static const String dailyAlertsNeedPlus =
      'تنبيهات حد الصرف اليومي من مزايا نبيه بلس';
  static const String actionFailed = 'تعذّر تنفيذ العملية، حاول مرة أخرى';
}
