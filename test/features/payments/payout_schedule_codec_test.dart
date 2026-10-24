import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/features/payments/data/payout_schedule_caches.dart';
import 'package:rateby/features/payments/domain/payout_catalog.dart';
import 'package:rateby/features/payments/domain/payout_program.dart';
import 'package:rateby/features/payments/domain/payout_schedule.dart';
import 'package:rateby/features/payments/domain/payout_schedule_codec.dart';
import 'package:rateby/features/payments/domain/payout_schedule_repository.dart';

import '../../support/fake_payout_source.dart';

PayoutSchedule? decode(Object? doc) =>
    PayoutScheduleCodec.decode(doc, source: PayoutScheduleSource.remote);

void main() {
  test('decodes a minimal program and applies defaults', () {
    final schedule = decode(scheduleDoc([programDoc(day: 27)]))!;
    final p = schedule.programs.single;
    expect(p.id, 'p1');
    expect(p.kind, PayoutKind.other);
    expect(p.certainty, PayoutCertainty.expected);
    expect(p.dayOfMonth, 27);
    expect(p.windowEndDay, isNull);
    expect(p.note, isEmpty);
    expect(schedule.source, PayoutScheduleSource.remote);
    expect(
      schedule.updatedAt,
      DateTime.fromMillisecondsSinceEpoch(1760000000000),
    );
  });

  test('skips invalid programs but keeps the valid ones', () {
    final schedule = decode(scheduleDoc([
      programDoc(id: 'ok'),
      programDoc(id: 'bad-day', day: 32),
      programDoc(id: 'zero', day: 0),
      programDoc(id: 'fraction')..['dayOfMonth'] = 12.5,
      programDoc(id: 'bad-cat', category: 'nope'),
      programDoc(id: 'no-title', title: '   '),
      programDoc(id: 'bad-window', day: 25, windowEndDay: 25),
      programDoc(id: 'off', active: false),
      {'id': 'missing-everything'},
    ]))!;
    expect(schedule.programs.map((p) => p.id), ['ok']);
  });

  test('accepts day numbers delivered as doubles', () {
    final schedule = decode(scheduleDoc([
      programDoc(day: 25)..['dayOfMonth'] = 25.0,
    ]))!;
    expect(schedule.programs.single.dayOfMonth, 25);
  });

  test('keeps the first of duplicate ids', () {
    final schedule = decode(scheduleDoc([
      programDoc(title: 'الأول'),
      programDoc(title: 'الثاني'),
    ]))!;
    expect(schedule.programs.single.title, 'الأول');
  });

  test('a document with no usable program decodes to null', () {
    expect(decode(null), isNull);
    expect(decode('text'), isNull);
    expect(decode({'programs': 'x'}), isNull);
    expect(decode(scheduleDoc([])), isNull);
    expect(decode(scheduleDoc([programDoc(day: 99)])), isNull);
  });

  test('encode → decode round trips the built-in catalog', () {
    const original = PayoutSchedule.catalog();
    final copy = PayoutScheduleCodec.decode(
      PayoutScheduleCodec.encode(original),
      source: PayoutScheduleSource.cache,
    )!;
    expect(copy.programs.length, original.programs.length);
    for (var i = 0; i < copy.programs.length; i++) {
      final a = copy.programs[i];
      final b = PayoutCatalog.programs[i];
      expect(
        (a.id, a.kind, a.category, a.certainty, a.dayOfMonth, a.windowEndDay),
        (b.id, b.kind, b.category, b.certainty, b.dayOfMonth, b.windowEndDay),
      );
      expect((a.title, a.note, a.windowNote), (b.title, b.note, b.windowNote));
    }
  });

  group('cache codec', () {
    test('round trips', () {
      final schedule = decode(scheduleDoc([programDoc()]))!;
      final fetchedAt = DateTime(2026, 10, 20, 8);
      final raw = PayoutCacheCodec.encode(
        CachedPayoutSchedule(schedule: schedule, fetchedAt: fetchedAt),
      );
      final back = PayoutCacheCodec.decode(raw)!;
      expect(back.fetchedAt, fetchedAt);
      expect(back.schedule.programs.single.id, 'p1');
      expect(back.schedule.source, PayoutScheduleSource.cache);
      expect(back.schedule.updatedAt, schedule.updatedAt);
    });

    test('garbage is ignored instead of crashing', () {
      expect(PayoutCacheCodec.decode('not json'), isNull);
      expect(PayoutCacheCodec.decode('{}'), isNull);
      expect(PayoutCacheCodec.decode('{"fetchedAt":"x","doc":{}}'), isNull);
    });
  });
}
