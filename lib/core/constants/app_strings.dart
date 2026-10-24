/// User-facing copy in one place so screens contain no inline literals and
/// the app can later migrate to ARB / `gen-l10n` with a mechanical change.
abstract final class AppStrings {
  // ── Brand ───────────────────────────────────────────────────────────────
  static const String appName = 'نبيه';
  static const String appTagline = 'التحكم المالي الذكي';
  static const String currencySymbol = 'ر.س';

  // ── Navigation ──────────────────────────────────────────────────────────
  static const String navHome = 'الرئيسية';
  static const String navGoals = 'الأهداف';
  static const String navPayments = 'الصرف';
  static const String navUpgrade = 'الترقية';
  static const String navSettings = 'الإعدادات';

  // ── Top bar ─────────────────────────────────────────────────────────────
  static const String notifications = 'التنبيهات';
  static const String help = 'المساعدة والمعلومات';

  // ── Home ────────────────────────────────────────────────────────────────
  static const String greetingMorning = 'صباح الخير';
  static const String greetingEvening = 'مساء الخير';
  static const String todayPrefix = 'اليوم';

  static const String healthOnTrack = 'ميزانية منضبطة';
  static const String healthNearLimit = 'اقتربت من الحد اليومي';
  static const String healthExceeded = 'تجاوزت الحد اليومي';

  static const String dailyAllowanceLabel = 'المصروف اليومي المتاح';
  static const String dailyAllowanceOverLimit = 'تجاوزت حد اليوم';
  static const String leftOfTodayPrefix = 'متبقي لليوم من أصل';
  static const String remainingShort = 'باقٍ';

  static String spentToday(String amount, String percent) =>
      'مصروف اليوم: $amount $currencySymbol ($percent%)';

  static String remainingPercent(String percent) => '$remainingShort $percent%';

  static const String payday = 'تاريخ';
  static const String paydayToday = 'ينزل الراتب اليوم';
  static String nextPaydayCaption(String month) =>
      'موعد إيداع الراتب القادم لشهر $month';
  static const String ofTheMonth = 'من الشهر';

  static const String logExpense = 'تسجيل مصروف جديد';

  static const String fixedExpensesTitle = 'المصاريف الثابتة المقتطعة';
  static String fixedExpensesSummary(String paid, String total) =>
      'مدفوع $paid من أصل $total $currencySymbol';

  static const String statusCompleted = 'مكتمل';
  static const String statusDueSoon = 'قريب الصرف';
  static const String statusScheduled = 'مجدول';

  static String deductedOn(int day, String month) =>
      'تم الاستقطاع بنجاح في $day $month';
  static const String autoPayScheduled = 'مجدولة للسداد التلقائي';
  static String dueIn(String afterDays) => 'دفعة مستحقة $afterDays';
  static String scheduledOn(int day, String month) =>
      'مجدولة في $day $month';

  static const String carFinance = 'قسط تمويل السيارة';

  // Demo goals (see LocalBudgetStore.demo)
  static const String goalEmergency = 'صندوق الطوارئ';
  static const String goalEmergencyNote = 'أمان مالي لتغطية نفقات 3 أشهر';
  static const String goalTravel = 'سفرة الإجازة';
  static const String goalTravelNote = 'رحلة الصيف العائلية السنوية';
  static const String goalCar = 'دفعة سيارة جديدة';
  static const String goalCarNote = 'الدفعة الأولى للشراء بدون تمويل عالي';
  static const String bnpl = 'أقساط تابي وتمارا';
  static const String utilities = 'فواتير الكهرباء والإنترنت';

  static const String sponsoredTag = 'إعلان مدعوم';
  static const String upgradeBannerTitle = 'تجربة أنقى وبدون مقاطعة';
  static const String upgradeBannerBody =
      'احصل على "نبيه بلس" بدون إعلانات بـ 9 ر.س/شهر';
  static const String upgradeCta = 'ترقية';

  static const String loadError = 'تعذّر تحميل البيانات';
  static const String retry = 'إعادة المحاولة';

  // ── Add expense ─────────────────────────────────────────────────────────
  static const String addExpenseTitle = 'تسجيل مصروف';
  static const String back = 'رجوع';
  static const String remainingToday = 'الحد المتبقي لليوم';
  static const String instantBadge = 'تسجيل فوري';
  static const String addExpenseSheetTitle = 'تسجيل مصروف جديد';
  static const String addExpenseSubtitle =
      'بدون حقول إضافية أو تعقيد، حدد المبلغ واضغط حفظ ليُخصم فوراً.';
  static const String amountDue = 'المبلغ المستحق';
  static const String commonAmounts = 'المبالغ الشائعة';
  static const String oneTap = 'ضغطة واحدة';
  static const String backspace = 'مسح رقم';
  static const String saveExpense = 'حفظ المصروف فوراً';
  static const String expenseNoteLabel = 'ما الذي صرفت عليه؟ (اختياري)';
  static const String expenseNoteHint = 'مثال: بقالة، قهوة، بنزين';
  static const String savingExpense = 'جارٍ الحفظ…';

  static const String hintPrompt = 'اضغط على الأرقام بالأسفل أو اختر مبلغاً سريعاً';
  static const String hintInvalid = 'يرجى تحديد مبلغ أكبر من صفر';
  static String hintDeduct(String amount) =>
      'سيتم خصم $amount $currencySymbol من رصيد اليوم';
  static String hintOverLimit(String over) =>
      'يتجاوز الحد المتبقي بمقدار $over $currencySymbol';

  static const String savedTitle = 'تم تسجيل المصروف بنجاح';
  static String savedBody(String amount) =>
      'تم خصم $amount $currencySymbol بنجاح وتحديث سقف المصروف.';
  static const String saveFailed = 'تعذّر حفظ المصروف، حاول مرة أخرى';

}
