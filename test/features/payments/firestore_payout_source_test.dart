import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/features/payments/data/firestore_payout_source.dart';
import 'package:rateby/features/payments/data/payout_schedule_caches.dart';
import 'package:rateby/features/payments/data/remote_payout_schedule_repository.dart';
import 'package:rateby/features/payments/domain/payout_schedule.dart';
import 'package:rateby/features/payments/domain/payout_schedule_codec.dart';

import '../../support/test_overrides.dart';

const int publishedMs = 1760000000000;

Future<FakeFirebaseFirestore> publish(Map<String, Object?> data) async {
  final firestore = FakeFirebaseFirestore();
  await firestore.doc(FirestorePayoutSource.documentPath).set(data);
  return firestore;
}

Map<String, Object?> program(String id, int day) => {
      'id': id,
      'title': 'برنامج $id',
      'category': 'support',
      'dayOfMonth': day,
    };

void main() {
  test('returns null while nothing has been published', () async {
    final source = FirestorePayoutSource(FakeFirebaseFirestore());
    expect(await source.fetch(), isNull);
  });

  test('turns the server Timestamp into epoch milliseconds', () async {
    final source = FirestorePayoutSource(
      await publish({
        'updatedAt': Timestamp.fromMillisecondsSinceEpoch(publishedMs),
        'updatedBy': 'admin@example.com',
        'programs': [program('a', 5)],
      }),
    );

    final doc = await source.fetch();

    expect(doc!['updatedAt'], publishedMs);
    final schedule = PayoutScheduleCodec.decode(
      doc,
      source: PayoutScheduleSource.remote,
    );
    expect(schedule!.programs.single.id, 'a');
    expect(
      schedule.updatedAt,
      DateTime.fromMillisecondsSinceEpoch(publishedMs),
    );
  });

  test('a document without a timestamp still decodes', () async {
    final source = FirestorePayoutSource(
      await publish({'programs': [program('a', 5)]}),
    );

    final doc = await source.fetch();

    expect(doc!['updatedAt'], isNull);
    expect(
      PayoutScheduleCodec.decode(doc, source: PayoutScheduleSource.remote),
      isNotNull,
    );
  });

  test('repository + Firestore: downloads, then keeps it in the cache',
      () async {
    final firestore = await publish({
      'updatedAt': Timestamp.fromMillisecondsSinceEpoch(publishedMs),
      'programs': [program('a', 5), program('b', 20)],
    });
    final cache = MemoryPayoutCache();
    final repository = RemotePayoutScheduleRepository(
      cache: cache,
      clock: () => testNow,
      remote: FirestorePayoutSource(firestore),
    );
    addTearDown(repository.dispose);

    expect(await repository.refresh(), isTrue);

    expect(cache.read()!.schedule.programs.map((p) => p.id), ['a', 'b']);
    expect(cache.read()!.fetchedAt, testNow);
  });
}
