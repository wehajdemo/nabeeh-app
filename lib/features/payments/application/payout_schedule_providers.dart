import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/providers/clock_provider.dart';
import 'package:rateby/features/payments/data/payout_schedule_caches.dart';
import 'package:rateby/features/payments/data/remote_payout_schedule_repository.dart';
import 'package:rateby/features/payments/domain/payout_schedule.dart';
import 'package:rateby/features/payments/domain/payout_schedule_repository.dart';

/// Where downloaded schedules are kept. `main` overrides it with
/// `SharedPrefsPayoutCache`.
final payoutScheduleCacheProvider = Provider<PayoutScheduleCache>(
  (ref) => MemoryPayoutCache(),
);

/// Server the admin dashboard publishes to. `null` (default) means Firebase is
/// not set up, so the app uses the cached or built-in schedule.
final payoutRemoteSourceProvider = Provider<PayoutRemoteSource?>((ref) => null);

final payoutScheduleRepositoryProvider = Provider<PayoutScheduleRepository>((
  ref,
) {
  final repository = RemotePayoutScheduleRepository(
    cache: ref.watch(payoutScheduleCacheProvider),
    clock: ref.watch(clockProvider),
    remote: ref.watch(payoutRemoteSourceProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

/// The payout programs to show: cache / built-in list first, then the copy
/// published from the admin dashboard.
final payoutScheduleProvider = StreamProvider<PayoutSchedule>(
  (ref) => ref.watch(payoutScheduleRepositoryProvider).watch(),
);
