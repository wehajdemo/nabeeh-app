import 'package:flutter/foundation.dart';
import 'package:rateby/core/money/money.dart';

/// A manual change to a goal's saved balance chosen in the balance sheet.
@immutable
class GoalBalanceChange {
  const GoalBalanceChange({required this.isDeposit, required this.amount});

  final bool isDeposit;
  final Money amount;
}
