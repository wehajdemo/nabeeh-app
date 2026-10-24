import 'package:flutter/foundation.dart';
import 'package:rateby/features/payments/domain/payout_schedule.dart';

/// Provides the payout programs managed from the admin dashboard.
abstract interface class PayoutScheduleRepository {
  /// Emits the best schedule available right away (cache or built-in list),
  /// then the downloaded one when it arrives or changes.
  Stream<PayoutSchedule> watch();

  /// Downloads the latest schedule now. Returns `false` if it could not be
  /// fetched or was invalid — the current schedule then stays in place.
  Future<bool> refresh();
}

/// Where the admin-published document is downloaded from (Firestore).
abstract interface class PayoutRemoteSource {
  /// The raw document: `{programs: [...], updatedAt: <epoch ms>}`, or `null`
  /// if no schedule has been published yet. Throws when offline.
  Future<Map<String, Object?>?> fetch();
}

@immutable
class CachedPayoutSchedule {
  const CachedPayoutSchedule({required this.schedule, required this.fetchedAt});

  final PayoutSchedule schedule;
  final DateTime fetchedAt;
}

/// Keeps the last downloaded schedule so the app works offline.
abstract interface class PayoutScheduleCache {
  CachedPayoutSchedule? read();
  Future<void> write(CachedPayoutSchedule value);
}
