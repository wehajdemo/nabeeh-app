import 'package:flutter/foundation.dart';
import 'package:rateby/features/payments/domain/payout_program.dart';

enum PayoutStatus {
  /// Date fixed by the paying authority.
  confirmed,

  /// Date inferred from past behaviour or varies by institution.
  expected,

  /// Paid recently — the card shows the last deposit and the next one.
  paid,
}

/// A program evaluated against "today".
@immutable
class PayoutInfo {
  const PayoutInfo({
    required this.program,
    required this.status,
    required this.nextPayout,
    required this.daysUntilNext,
    required this.cycleProgress,
    required this.wasShiftedForWeekend,
    this.lastPayout,
    this.windowEnd,
    this.daysUntilWindowEnd,
  });

  final PayoutProgram program;
  final PayoutStatus status;

  /// Next deposit date (for windows: the first day of the window).
  final DateTime nextPayout;

  /// Most recent deposit on or before today (fixed-date programs only).
  final DateTime? lastPayout;

  /// Last day of the window, for window programs.
  final DateTime? windowEnd;

  final int daysUntilNext;
  final int? daysUntilWindowEnd;

  /// 0‥1 — how far we are between the last and the next deposit.
  final double cycleProgress;

  /// The nominal day fell on a Friday / Saturday and was moved.
  final bool wasShiftedForWeekend;

  bool get isWindow => windowEnd != null;
  bool get isToday => daysUntilNext == 0;
}
