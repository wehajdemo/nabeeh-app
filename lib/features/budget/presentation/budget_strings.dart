/// Copy shared by onboarding and settings (commitments, payday, salary).
abstract final class BudgetStrings {
  // Categories
  static const String categoryLoan = 'قسط تمويل';
  static const String categoryLoanNote = 'خصم شهري مباشر';
  static const String categoryBnpl = 'تقسيط (تابي وتمارا)';
  static const String categoryBnplNote = 'دفعات مجزأة';
  static const String categoryBills = 'فواتير';
  static const String categoryBillsNote = 'كهرباء واتصالات';

  // Commitment form
  static const String addCommitmentTitle = 'إضافة التزام أو فاتورة';
  static const String addCommitmentSubtitle = 'مبلغ ثابت يُستقطع كل شهر';
  static const String commitmentName = 'اسم الالتزام';
  static const String commitmentNameHint = 'مثال: قسط السيارة';
  static const String commitmentAmount = 'المبلغ الشهري';
  static const String commitmentType = 'النوع';
  static const String saveCommitment = 'إضافة الالتزام';
  static const String addCommitmentCta = '+ إضافة التزام أو فاتورة جديدة';
  static const String removeCommitment = 'حذف الالتزام';
  static const String nameRequired = 'أدخل اسماً للالتزام';
  static const String amountRequired = 'أدخل مبلغاً أكبر من صفر';

  static String commitmentCount(int n) {
    if (n == 0) return 'لا التزامات';
    if (n == 1) return 'التزام واحد';
    if (n == 2) return 'التزامان';
    if (n <= 10) return '$n التزامات';
    return '$n التزاماً';
  }

  // Salary
  static const String editSalaryTitle = 'تعديل الراتب الشهري';
  static const String editSalarySubtitle = 'المبلغ الفعلي الذي ينزل في حسابك';
  static const String salaryLabel = 'الراتب الشهري المحول';
  static const String save = 'حفظ';

  // Payday
  static const String paydayTitle = 'يوم نزول الراتب';
  static const String paydaySubtitle = 'اختر الموعد الذي يصلك فيه راتبك';
  static const String defaultTag = 'الافتراضي';
  static const String customDayTitle = 'يوم مخصص';
  static const String customDayNote = 'حدد يوماً محدداً من 1 إلى 31 للشهر';
  static const String selectedDay = 'اليوم المختار:';
  static String dayOfMonth(int day) => 'يوم $day';

  static const String payday27Title = 'يوم 27 من كل شهر ميلادي';
  static const String payday27Note = 'رواتب موظفي القطاع الحكومي والمدني في السعودية';
  static const String payday1Title = 'يوم 1 من الشهر';
  static const String payday1Note = 'المتقاعدون، التأمينات الاجتماعية، وشركات خاصة';
  static const String payday25Title = 'يوم 25 من كل شهر';
  static const String payday25Note = 'البنوك والشركات والمؤسسات الخاصة';
}
