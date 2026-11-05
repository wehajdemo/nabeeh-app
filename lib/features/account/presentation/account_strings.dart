/// Copy for sign-in and the account copy of the budget data.
abstract final class AccountStrings {
  static const String signInTitle = 'سجّل دخولك';
  static const String signInBodySubscribe =
      'الاشتراك يُربط بحسابك، فيرجع لك اشتراكك وبياناتك على أي جهاز جديد أو بعد إعادة ضبط الجوال.';
  static const String signInBodyRestore =
      'سجّل دخولك لنستعيد اشتراكك وبياناتك المحفوظة في حسابك.';
  static const String signInBodyOptional =
      'اختياري: عند تسجيل الدخول تُحفظ ميزانيتك ومصاريفك وأهدافك في حسابك، وترجع لك على أي جهاز.';
  static const String continueWithGoogle = 'المتابعة بحساب Google';
  static const String continueWithApple = 'المتابعة مع Apple';
  static const String notNow = 'ليس الآن';
  static const String signInFailed = 'تعذّر تسجيل الدخول، حاول مرة أخرى';
  static const String signedIn = 'تم تسجيل الدخول';

  // Onboarding
  static const String haveAccount = 'عندك حساب سابق؟ سجّل دخولك لاستعادة بياناتك';

  // Settings
  static const String section = 'الحساب والنسخ الاحتياطي';
  static const String signInTile = 'تسجيل الدخول';
  static const String signInTileSubtitle =
      'اختياري، لحفظ بياناتك واشتراكك على أي جهاز';
  static String signedInAs(String who) => 'مسجّل باسم $who';
  static const String backupOk = 'بياناتك محفوظة في حسابك تلقائياً';
  static const String backupSyncing = 'جارٍ المزامنة…';
  static const String backupFailed = 'تعذّر الحفظ في حسابك، سنعيد المحاولة';
  static const String signOut = 'تسجيل الخروج';
  static const String signOutSubtitle = 'تبقى بياناتك على هذا الجهاز';
  static const String deleteCloud = 'حذف النسخة المحفوظة في حسابي';
  static const String deleteCloudSubtitle =
      'تُحذف من الخادم، وتبقى بياناتك على جهازك';
  static const String deleteCloudConfirm =
      'سنحذف نسختك المحفوظة في حسابك. بياناتك على هذا الجهاز لا تتأثر، لكنها لن تعود إليك على جهاز جديد.';
  static const String delete = 'حذف';
  static const String cloudDeleted = 'تم حذف النسخة المحفوظة';
  static const String cloudDeleteFailed = 'تعذّر الحذف، حاول مرة أخرى';
  static const String deleteAccount = 'حذف الحساب';
  static const String deleteAccountSubtitle =
      'يحذف حسابك ونسختك المحفوظة نهائياً';
  static const String deleteAccountConfirm =
      'سنحذف حسابك ونسختك المحفوظة فيه نهائياً، ولا يمكن التراجع. بياناتك على هذا الجهاز تبقى.\n\nإذا كان عندك اشتراك في نبيه بلس فهو لا يُلغى تلقائياً: ألغه من إعدادات اشتراكات Apple أو Google Play.';
  static const String accountDeleted = 'تم حذف حسابك';
  static const String accountDeleteFailed = 'تعذّر حذف الحساب، حاول مرة أخرى';

  // Conflict
  static const String conflictTitle = 'وجدنا نسخة محفوظة في حسابك';
  static const String conflictBody =
      'هذا الجهاز وحسابك يحتويان بيانات مختلفة. أيهما تريد الاحتفاظ به؟ الآخر سيُستبدل.';
  static const String useCloud = 'استعادة نسخة الحساب';
  static const String keepPhone = 'الاحتفاظ ببيانات هذا الجهاز';
}
