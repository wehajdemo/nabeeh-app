import 'package:flutter/foundation.dart';
import 'package:rateby/features/payments/domain/payout_catalog.dart';
import 'package:rateby/features/payments/domain/payout_program.dart';

enum PayoutScheduleSource {
  /// Built-in fallback list (nothing downloaded yet).
  catalog,

  /// Last copy downloaded from the admin dashboard, read from disk.
  cache,

  /// Freshly downloaded from the admin dashboard.
  remote,
}

/// The list of payout programs plus where it came from.
@immutable
class PayoutSchedule {
  const PayoutSchedule({
    required this.programs,
    required this.source,
    this.updatedAt,
  });

  const PayoutSchedule.catalog()
      : programs = PayoutCatalog.programs,
        source = PayoutScheduleSource.catalog,
        updatedAt = null;

  final List<PayoutProgram> programs;
  final PayoutScheduleSource source;

  /// When an admin last published the schedule (`null` for the catalog).
  final DateTime? updatedAt;

  bool get isManaged => source != PayoutScheduleSource.catalog;
}
