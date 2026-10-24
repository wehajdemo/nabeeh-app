import 'package:flutter/foundation.dart';
import 'package:rateby/core/money/money.dart';

enum FixedExpenseCategory { carFinance, buyNowPayLater, utilities }

enum FixedExpenseStatus {
  /// Already deducted this cycle.
  completed,

  /// Will be deducted within the next few days.
  dueSoon,

  /// Planned for later in the cycle.
  scheduled,
}

/// A recurring monthly commitment (loan installment, BNPL, bills…).
@immutable
class FixedExpense {
  const FixedExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.status,
    required this.date,
    this.isAutoPay = false,
  });

  /// A commitment reserved automatically on [date] (usually next payday).
  factory FixedExpense.scheduled({
    required String id,
    required String title,
    required Money amount,
    required FixedExpenseCategory category,
    required DateTime date,
  }) {
    return FixedExpense(
      id: id,
      title: title,
      amount: amount,
      category: category,
      status: FixedExpenseStatus.scheduled,
      date: date,
      isAutoPay: true,
    );
  }

  final String id;
  final String title;
  final Money amount;
  final FixedExpenseCategory category;
  final FixedExpenseStatus status;

  /// Deduction date (past for completed, future otherwise).
  final DateTime date;

  /// Paid automatically from the user's account.
  final bool isAutoPay;

  @override
  bool operator ==(Object other) =>
      other is FixedExpense &&
      other.id == id &&
      other.title == title &&
      other.amount == amount &&
      other.category == category &&
      other.status == status &&
      other.date == date &&
      other.isAutoPay == isAutoPay;

  @override
  int get hashCode =>
      Object.hash(id, title, amount, category, status, date, isAutoPay);
}
