import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/features/payments/data/payout_schedule_caches.dart';
import 'package:rateby/features/payments/data/remote_payout_schedule_repository.dart';
import 'package:rateby/features/payments/domain/payout_schedule.dart';
import 'package:rateby/features/payments/domain/payout_schedule_codec.dart';
import 'package:rateby/features/payments/domain/payout_schedule_repository.dart';

import '../../support/fake_payout_source.dart';
import '../../support/test_overrides.dart';

CachedPayoutSchedule cached(DateTime fetchedAt) => CachedPayoutSchedule(
      schedule: PayoutScheduleCodec.decode(
        scheduleDoc([programDoc(id: 'cached')]),
        source: PayoutScheduleSource.cache,
      )!,
      fetchedAt: fetchedAt,
    );

RemotePayoutScheduleRepository makeRepo({
  FakePayoutSource? remote,
  PayoutScheduleCache? cache,
}) {
  final repo = RemotePayoutScheduleRepository(
    cache: cache ?? MemoryPayoutCache(),
    clock: () => testNow,
    remote: remote,
  );
  addTearDown(repo.dispose);
  return repo;
}

void main() {
  test('without Firebase it serves the built-in catalog', () async {
    final first = await makeRepo().watch().first;
    expect(first.source, PayoutScheduleSource.catalog);
    expect(first.programs, hasLength(5));
    expect(first.isManaged, isFalse);
  });

  test('emits the catalog first, then the downloaded schedule, and caches it',
      () async {
    final remote = FakePayoutSource(doc: scheduleDoc([programDoc(id: 'live')]));
    final cache = MemoryPayoutCache();
    final repo = makeRepo(remote: remote, cache: cache);

    final events = await repo.watch().take(2).toList();

    expect(events[0].source, PayoutScheduleSource.catalog);
    expect(events[1].source, PayoutScheduleSource.remote);
    expect(events[1].programs.single.id, 'live');
    expect(remote.calls, 1);
    expect(cache.read()!.schedule.programs.single.id, 'live');
    expect(cache.read()!.fetchedAt, testNow);
  });

  test('a fresh cache is served without any download', () async {
    final remote = FakePayoutSource(doc: scheduleDoc([programDoc(id: 'live')]));
    final repo = makeRepo(
      remote: remote,
      cache: MemoryPayoutCache(cached(testNow.subtract(const Duration(hours: 2)))),
    );

    final first = await repo.watch().first;
    await settle();

    expect(first.programs.single.id, 'cached');
    expect(first.source, PayoutScheduleSource.cache);
    expect(remote.calls, 0);
  });

  test('a stale cache is shown at once and then refreshed', () async {
    final remote = FakePayoutSource(doc: scheduleDoc([programDoc(id: 'live')]));
    final repo = makeRepo(
      remote: remote,
      cache: MemoryPayoutCache(cached(testNow.subtract(const Duration(days: 2)))),
    );

    final events = await repo.watch().take(2).toList();

    expect(events[0].programs.single.id, 'cached');
    expect(events[1].programs.single.id, 'live');
    expect(remote.calls, 1);
  });

  test('offline keeps the current schedule and reports failure', () async {
    final remote = FakePayoutSource(error: Exception('offline'));
    final repo = makeRepo(remote: remote);

    final first = await repo.watch().first;
    expect(await repo.refresh(), isFalse);

    expect(first.source, PayoutScheduleSource.catalog);
  });

  test('an invalid or missing document never replaces the schedule', () async {
    final remote = FakePayoutSource(doc: scheduleDoc([programDoc(day: 99)]));
    final cache = MemoryPayoutCache();
    final repo = makeRepo(remote: remote, cache: cache);

    expect(await repo.refresh(), isFalse);
    remote.doc = null;
    expect(await repo.refresh(), isFalse);
    expect(cache.read(), isNull);
  });

  test('refresh forces a download even when the cache is fresh', () async {
    final remote = FakePayoutSource(doc: scheduleDoc([programDoc(id: 'live')]));
    final repo = makeRepo(
      remote: remote,
      cache: MemoryPayoutCache(cached(testNow)),
    );

    expect(await repo.refresh(), isTrue);
    expect(remote.calls, 1);
  });

  test('simultaneous refreshes share one download', () async {
    final remote = FakePayoutSource(doc: scheduleDoc([programDoc()]));
    final repo = makeRepo(remote: remote);

    final results = await Future.wait([repo.refresh(), repo.refresh()]);

    expect(results, [true, true]);
    expect(remote.calls, 1);
  });
}
