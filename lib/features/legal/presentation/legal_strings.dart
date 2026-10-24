import 'package:rateby/features/legal/domain/legal_content.dart';

abstract final class LegalStrings {
  static String effective(String date) => 'تاريخ السريان: $date';
  static const String loadFailed = 'تعذّر تحميل الصفحة';
  static const String contactButton = 'تواصل معنا';
  static const String supportSubject = 'دعم تطبيق نبيه';
  static String mailFailed(String email) =>
      'تعذّر فتح تطبيق البريد. راسلنا على $email';

  static String title(LegalKind kind) => switch (kind) {
        LegalKind.privacy => 'سياسة الخصوصية',
        LegalKind.terms => 'شروط الاستخدام',
        LegalKind.support => 'الدعم والمساعدة',
      };
}
