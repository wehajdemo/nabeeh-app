import 'package:flutter/foundation.dart';
import 'package:rateby/core/money/money.dart';

/// A single logged day-to-day expense.
@immutable
class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.createdAt,
    this.note,
  });

  final String id;
  final Money amount;
  final DateTime createdAt;

  /// Optional free-text description (e.g. "بقالة"); null when not given.
  final String? note;
}
