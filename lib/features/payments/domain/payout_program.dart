import 'package:flutter/foundation.dart';

enum PayoutKind {
  governmentSalary,
  citizenAccount,
  socialSecurity,
  pension,
  studentStipend,

  /// Any program added from the admin dashboard without a dedicated icon.
  other,
}

/// Which filter tab a program belongs to.
enum PayoutCategory { government, support, retireesAndStudents }

/// Whether the date is officially fixed or only an expectation.
enum PayoutCertainty { confirmed, expected }

/// A recurring payment (salary, benefit, stipend) with a monthly rule.
@immutable
class PayoutProgram {
  const PayoutProgram({
    required this.id,
    required this.kind,
    required this.category,
    required this.title,
    required this.provider,
    required this.certainty,
    required this.dayOfMonth,
    this.windowEndDay,
    this.note = '',
    this.windowNote = '',
  });

  final String id;
  final PayoutKind kind;
  final PayoutCategory category;
  final String title;
  final String provider;
  final PayoutCertainty certainty;

  /// The payout day (or the first day of the window).
  final int dayOfMonth;

  /// Last day of the window, for programs whose date varies by institution.
  final int? windowEndDay;

  /// Short remark shown in the card footer.
  final String note;

  /// Extra remark for window programs ("حسب اعتماد كل جامعة").
  final String windowNote;

  bool get isWindow => windowEndDay != null;
}
