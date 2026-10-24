import 'dart:async';

import 'package:rateby/features/payments/domain/payout_schedule.dart';
import 'package:rateby/features/payments/domain/payout_schedule_codec.dart';
import 'package:rateby/features/payments/domain/payout_schedule_repository.dart';

/// Serves the schedule from the cache / built-in list immediately and keeps
/// it fresh from [remote] — at most one download per [staleAfter] unless
/// [refresh] is called (pull-to-refresh).
///
/// Cost note: the whole schedule is a single Firestore document, so one
/// refresh is exactly one read.
class RemotePayoutScheduleRepository implements PayoutScheduleRepository {
  RemotePayoutScheduleRepository({
    required PayoutScheduleCache cache,
    required DateTime Function() clock,
    this.remote,
    this.staleAfter = const Duration(hours: 24),
  })  : _cache = cache,
        _clock = clock {
    final cached = cache.read();
    _current = cached?.schedule ?? const PayoutSchedule.catalog();
    _fetchedAt = cached?.fetchedAt;
  }

  /// `null` when Firebase is not configured — the app then stays on the
  /// cached or built-in schedule.
  final PayoutRemoteSource? remote;
  final Duration staleAfter;

  final PayoutScheduleCache _cache;
  final DateTime Function() _clock;
  final StreamController<PayoutSchedule> _changes =
      StreamController<PayoutSchedule>.broadcast();

  late PayoutSchedule _current;
  DateTime? _fetchedAt;
  Future<bool>? _inFlight;

  void dispose() => _changes.close();

  @override
  Stream<PayoutSchedule> watch() {
    late final StreamController<PayoutSchedule> out;
    StreamSubscription<PayoutSchedule>? subscription;

    out = StreamController<PayoutSchedule>(
      onListen: () {
        out.add(_current);
        subscription = _changes.stream.listen(out.add);
        _refreshIfStale();
      },
      onCancel: () => subscription?.cancel(),
    );
    return out.stream;
  }

  void _refreshIfStale() {
    final fetchedAt = _fetchedAt;
    final isFresh =
        fetchedAt != null && _clock().difference(fetchedAt) < staleAfter;
    if (remote == null || isFresh) return;
    unawaited(refresh());
  }

  @override
  Future<bool> refresh() => _inFlight ??= _download().whenComplete(() {
        _inFlight = null;
      });

  Future<bool> _download() async {
    final source = remote;
    if (source == null) return false;
    try {
      final doc = await source.fetch();
      final schedule = PayoutScheduleCodec.decode(
        doc,
        source: PayoutScheduleSource.remote,
      );
      if (schedule == null) return false;

      final now = _clock();
      _current = schedule;
      _fetchedAt = now;
      if (!_changes.isClosed) _changes.add(schedule);
      await _cache.write(CachedPayoutSchedule(schedule: schedule, fetchedAt: now));
      return true;
    } on Object {
      return false; // offline or cache write failed — keep what we have
    }
  }
}
