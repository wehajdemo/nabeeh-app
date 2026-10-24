import 'package:flutter/foundation.dart';
import 'package:rateby/features/payments/domain/payout_info.dart';
import 'package:rateby/features/payments/domain/payout_program.dart';
import 'package:rateby/features/payments/domain/payout_schedule.dart';

enum PayoutFilter {
  all,
  government,
  support,
  retireesAndStudents;

  bool accepts(PayoutProgram program) => switch (this) {
        all => true,
        government => program.category == PayoutCategory.government,
        support => program.category == PayoutCategory.support,
        retireesAndStudents =>
          program.category == PayoutCategory.retireesAndStudents,
      };
}

/// A program evaluated for today, plus whether the user asked to be reminded.
@immutable
class PayoutItem {
  const PayoutItem({required this.info, required this.alertEnabled});

  final PayoutInfo info;
  final bool alertEnabled;

  String get id => info.program.id;
}

@immutable
class PaymentsState {
  const PaymentsState({
    required this.items,
    required this.today,
    this.scheduleSource = PayoutScheduleSource.catalog,
    this.scheduleUpdatedAt,
  });

  final List<PayoutItem> items;
  final DateTime today;
  final PayoutScheduleSource scheduleSource;

  /// When the dates were last published from the dashboard, if ever.
  final DateTime? scheduleUpdatedAt;

  int get totalCount => items.length;

  List<PayoutItem> visible(PayoutFilter filter) =>
      [for (final i in items) if (filter.accepts(i.info.program)) i];

  /// The upcoming (not yet paid) item that arrives first — drawn as the
  /// highlighted card.
  String? nextDueId(PayoutFilter filter) {
    PayoutItem? best;
    for (final item in visible(filter)) {
      if (item.info.status == PayoutStatus.paid) continue;
      if (best == null || item.info.daysUntilNext < best.info.daysUntilNext) {
        best = item;
      }
    }
    return best?.id;
  }
}
