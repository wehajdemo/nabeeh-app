import 'package:rateby/features/payments/domain/payout_program.dart';

/// Built-in fallback payout rules, used until the first schedule published
/// from the admin dashboard has been downloaded.
///
/// Dates and remarks come from the product design and are static; verify them
/// against the official sources before shipping. The live list comes from
/// `payoutScheduleProvider`.
abstract final class PayoutCatalog {
  static const List<PayoutProgram> programs = [
    PayoutProgram(
      id: 'gov-salaries',
      kind: PayoutKind.governmentSalary,
      category: PayoutCategory.government,
      title: 'رواتب القطاع الحكومي',
      provider: 'الجهات المدنية والعسكرية',
      certainty: PayoutCertainty.confirmed,
      dayOfMonth: 27,
      note: 'يصرف في تمام 12:00 صباحاً',
    ),
    PayoutProgram(
      id: 'citizen-account',
      kind: PayoutKind.citizenAccount,
      category: PayoutCategory.support,
      title: 'حساب المواطن',
      provider: 'برنامج دعم الأسر المستحقة',
      certainty: PayoutCertainty.confirmed,
      dayOfMonth: 10,
      note: 'الدورة الشهرية المعتمدة (يوم 10)',
    ),
    PayoutProgram(
      id: 'social-security',
      kind: PayoutKind.socialSecurity,
      category: PayoutCategory.support,
      title: 'الضمان الاجتماعي المطور',
      provider: 'وزارة الموارد البشرية',
      certainty: PayoutCertainty.confirmed,
      dayOfMonth: 1,
      note: 'يصرف في بداية كل شهر ميلادي',
    ),
    PayoutProgram(
      id: 'retirees',
      kind: PayoutKind.pension,
      category: PayoutCategory.retireesAndStudents,
      title: 'رواتب المتقاعدين',
      provider: 'المؤسسة العامة للتأمينات الاجتماعية',
      certainty: PayoutCertainty.expected,
      dayOfMonth: 1,
      note: 'توحيد موعد الصرف ليوم 1 ميلادي',
    ),
    PayoutProgram(
      id: 'student-stipends',
      kind: PayoutKind.studentStipend,
      category: PayoutCategory.retireesAndStudents,
      title: 'مكافآت الطلاب والجامعات',
      provider: 'الجامعات السعودية الحكومية',
      certainty: PayoutCertainty.expected,
      dayOfMonth: 25,
      windowEndDay: 28,
      note: 'تختلف بيوم أو يومين باختلاف الجامعة',
      windowNote: 'حسب اعتماد كل جامعة',
    ),
  ];
}
