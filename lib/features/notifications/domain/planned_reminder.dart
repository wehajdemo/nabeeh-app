import 'package:flutter/foundation.dart';

enum ReminderKind { payout, dailyLimit }

/// One notification to be delivered at [at] (device-local wall-clock time).
@immutable
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.kind,
    required this.at,
    required this.title,
    required this.body,
  });

  /// Unique within one plan; the whole plan is replaced on every sync.
  final int id;
  final ReminderKind kind;
  final DateTime at;
  final String title;
  final String body;

  PlannedReminder withId(int newId) => PlannedReminder(
        id: newId,
        kind: kind,
        at: at,
        title: title,
        body: body,
      );

  @override
  bool operator ==(Object other) =>
      other is PlannedReminder &&
      other.id == id &&
      other.kind == kind &&
      other.at == at &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(id, kind, at, title, body);

  @override
  String toString() => 'PlannedReminder($id, ${kind.name}, $at, $body)';
}
