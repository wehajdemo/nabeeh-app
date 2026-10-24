import 'package:rateby/features/payments/domain/payout_program.dart';
import 'package:rateby/features/payments/domain/payout_schedule.dart';

/// Converts the dashboard's document to a [PayoutSchedule] and back.
///
/// Decoding is defensive: a malformed program is skipped instead of crashing
/// the app, and a document with no valid program decodes to `null` so the
/// caller keeps what it had.
abstract final class PayoutScheduleCodec {
  static PayoutSchedule? decode(
    Object? doc, {
    required PayoutScheduleSource source,
  }) {
    if (doc is! Map) return null;
    final raw = doc['programs'];
    if (raw is! List) return null;

    final seenIds = <String>{};
    final programs = <PayoutProgram>[];
    for (final item in raw) {
      final program = _program(item);
      if (program != null && seenIds.add(program.id)) programs.add(program);
    }
    if (programs.isEmpty) return null;

    final updatedMs = doc['updatedAt'];
    return PayoutSchedule(
      programs: List.unmodifiable(programs),
      source: source,
      updatedAt: updatedMs is int
          ? DateTime.fromMillisecondsSinceEpoch(updatedMs)
          : null,
    );
  }

  static Map<String, Object?> encode(PayoutSchedule schedule) => {
        'updatedAt': schedule.updatedAt?.millisecondsSinceEpoch,
        'programs': [
          for (final p in schedule.programs)
            {
              'id': p.id,
              'kind': p.kind.name,
              'category': p.category.name,
              'title': p.title,
              'provider': p.provider,
              'certainty': p.certainty.name,
              'dayOfMonth': p.dayOfMonth,
              'windowEndDay': p.windowEndDay,
              'note': p.note,
              'windowNote': p.windowNote,
              'active': true,
            },
        ],
      };

  static PayoutProgram? _program(Object? item) {
    if (item is! Map) return null;
    if (item['active'] == false) return null;

    final id = _text(item['id']);
    final title = _text(item['title']);
    final category = _enum(PayoutCategory.values, item['category']);
    final day = _day(item['dayOfMonth']);
    if (id == null || title == null || category == null || day == null) {
      return null;
    }

    int? windowEnd;
    if (item['windowEndDay'] != null) {
      windowEnd = _day(item['windowEndDay']);
      if (windowEnd == null || windowEnd <= day) return null;
    }

    return PayoutProgram(
      id: id,
      kind: _enum(PayoutKind.values, item['kind']) ?? PayoutKind.other,
      category: category,
      title: title,
      provider: _text(item['provider']) ?? '',
      certainty: _enum(PayoutCertainty.values, item['certainty']) ??
          PayoutCertainty.expected,
      dayOfMonth: day,
      windowEndDay: windowEnd,
      note: _text(item['note']) ?? '',
      windowNote: _text(item['windowNote']) ?? '',
    );
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// A whole number from 1 to 31 (Firestore may deliver ints as doubles).
  static int? _day(Object? value) {
    if (value is! num) return null;
    final day = value.toInt();
    if (day != value || day < 1 || day > 31) return null;
    return day;
  }

  static T? _enum<T extends Enum>(List<T> values, Object? name) {
    if (name is! String) return null;
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}
