import 'dart:convert';

import 'package:rateby/features/payments/domain/payout_schedule.dart';
import 'package:rateby/features/payments/domain/payout_schedule_codec.dart';
import 'package:rateby/features/payments/domain/payout_schedule_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// JSON form of a [CachedPayoutSchedule].
abstract final class PayoutCacheCodec {
  static String encode(CachedPayoutSchedule value) => jsonEncode({
        'fetchedAt': value.fetchedAt.toIso8601String(),
        'doc': PayoutScheduleCodec.encode(value.schedule),
      });

  /// `null` for anything unreadable, so a bad cache is simply ignored.
  static CachedPayoutSchedule? decode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final schedule = PayoutScheduleCodec.decode(
        map['doc'],
        source: PayoutScheduleSource.cache,
      );
      if (schedule == null) return null;
      return CachedPayoutSchedule(
        schedule: schedule,
        fetchedAt: DateTime.parse(map['fetchedAt'] as String),
      );
    } on Object {
      return null;
    }
  }
}

/// In-memory cache (default, and for tests).
class MemoryPayoutCache implements PayoutScheduleCache {
  MemoryPayoutCache([this._value]);

  CachedPayoutSchedule? _value;

  @override
  CachedPayoutSchedule? read() => _value;

  @override
  Future<void> write(CachedPayoutSchedule value) async => _value = value;
}

/// Cache on the device via `SharedPreferences`.
class SharedPrefsPayoutCache implements PayoutScheduleCache {
  const SharedPrefsPayoutCache(this._prefs);

  static const String _key = 'rateby.payout_schedule.v1';

  final SharedPreferences _prefs;

  @override
  CachedPayoutSchedule? read() {
    final raw = _prefs.getString(_key);
    return raw == null ? null : PayoutCacheCodec.decode(raw);
  }

  @override
  Future<void> write(CachedPayoutSchedule value) async {
    await _prefs.setString(_key, PayoutCacheCodec.encode(value));
  }
}
