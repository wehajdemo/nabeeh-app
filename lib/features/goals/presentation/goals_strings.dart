import 'package:rateby/core/constants/app_strings.dart';

/// Copy for the Goals tab.
abstract final class GoalsStrings {
  static const String title = 'أهدافي الادخارية';
  static const String subtitle = 'خططك المستقبلية تنمو مع كل راتب شهري';
  static const String newGoal = 'هدف جديد';

  static const String totalSaved = 'مجموع المدخرات المتراكمة';
  static String achievement(int percent) => 'معدل الإنجاز $percent%';
  static String ofTotal(String total) =>
      'من إجمالي $total ${AppStrings.currencySymbol}';
  static String remainingToFreedom(String amount) =>
      'المتبقي للوصول للحرية المالية: $amount ${AppStrings.currencySymbol}';
  static String activeGoals(int n) => switch (n) {
        0 => 'لا أهداف نشطة',
        1 => 'هدف نشط واحد',
        2 => 'هدفان نشطان',
        <= 10 => '$n أهداف نشطة',
        _ => '$n هدفاً نشطاً',
      };
  static const String totalDeduction = 'إجمالي الاستقطاع التلقائي:';
  static String perMonth(String amount) =>
      '$amount ${AppStrings.currencySymbol} / شهرياً';

  static const String activeSection = 'الأهداف النشطة';
  static const String linkedToDaily = 'مرتبطة بحسبة الصرف اليومي';

  static const String saved = 'تم حفظه';
  static const String remaining = 'المتبقي للهدف';
  static const String autoDeduct = 'استقطاع آلي:';
  static const String perMonthShort = '/ شهر';
  static const String edit = 'تعديل';
  static const String completed = 'مكتمل';

  static const String smartTitle = 'ذكاء الميزانية اليومية';
  static String smartBody(String total, int payDay) =>
      'يتم خصم استقطاعات الأهداف ($total ${AppStrings.currencySymbol}) مباشرة عند نزول الراتب في يوم $payDay ويُضاف تلقائياً إلى رصيد كل هدف، مما يضمن أن سقف إنفاقك اليومي يعكس رصيدك الحر الحقيقي بدون ضغوطات مالية.';

  static const String emptyTitle = 'ابدأ أول هدف ادخاري';
  static const String emptyBody =
      'حدد مبلغاً تريد الوصول إليه، وسنقتطع جزءاً منه تلقائياً من كل راتب.';

  // Form
  static const String addTitle = 'إضافة هدف ادخار جديد';
  static const String addSubtitle = 'حدد وجهتك المالية القادمة';
  static const String editTitle = 'تعديل الهدف';
  static const String goalName = 'اسم الهدف';
  static const String goalNameHint = 'مثال: رحلة العمرة';
  static const String targetAmount = 'المبلغ المستهدف';
  static const String monthlyAmount = 'الاستقطاع الشهري';
  static const String formInfo =
      'سيتم تحديث حاسبة الصرف اليومي تلقائياً فور حفظ الهدف.';
  static const String saveGoal = 'حفظ الهدف';
  static const String cancel = 'إلغاء';
  static const String nameRequired = 'أدخل اسماً للهدف';
  static const String targetRequired = 'أدخل مبلغاً مستهدفاً أكبر من صفر';
  static const String monthlyTooHigh = 'الاستقطاع أكبر من المبلغ المستهدف';
  // Balance sheet
  static const String addMoney = 'إضافة مبلغ';
  static const String withdrawMoney = 'سحب مبلغ';
  static const String balanceTitle = 'تحديث رصيد الهدف';
  static const String amountLabel = 'المبلغ';
  static const String amountRequired = 'أدخل مبلغاً أكبر من صفر';
  static const String withdrawTooHigh = 'المبلغ أكبر من الرصيد المدّخر';
  static String currentBalance(String amount) =>
      'الرصيد الحالي: $amount ${AppStrings.currencySymbol}';
  static const String confirmDeposit = 'إضافة إلى الهدف';
  static const String confirmWithdraw = 'سحب من الهدف';
  static const String balanceUpdated = 'تم تحديث رصيد الهدف';

  static const String saveFailed = 'تعذّر حفظ الهدف، حاول مرة أخرى';

  static String limitReached(int limit) =>
      'النسخة المجانية تتسع لـ $limit أهداف. اشترك في نبيه بلس لأهداف غير محدودة';
}
