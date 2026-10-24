import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/app_settings.dart';
import 'package:rateby/features/budget/domain/entities/appearance_mode.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/budget/domain/entities/expense.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';

/// Everything the store persists.
@immutable
class StoreData {
  const StoreData({
    required this.profile,
    required this.settings,
    required this.goals,
    required this.ledger,
    required this.nextId,
    this.lastCreditedPayday,
  });

  final BudgetProfile? profile;
  final AppSettings settings;
  final List<SavingsGoal> goals;
  final List<Expense> ledger;
  final int nextId;

  /// Payday up to which goal contributions were credited (`null` = never).
  final DateTime? lastCreditedPayday;
}

/// JSON (de)serialization of [StoreData]. [decode] returns `null` for
/// anything unreadable or from another schema version, so a corrupt file
/// can never crash the app — it just starts fresh.
abstract final class StoreDataCodec {
  static const int version = 1;

  static String encode(StoreData data) {
    return jsonEncode({
      'version': version,
      'nextId': data.nextId,
      'lastCreditedPayday': data.lastCreditedPayday?.toIso8601String(),
      'profile': data.profile == null ? null : _profileToJson(data.profile!),
      'settings': _settingsToJson(data.settings),
      'goals': [for (final g in data.goals) _goalToJson(g)],
      'ledger': [for (final e in data.ledger) _expenseToJson(e)],
    });
  }

  static StoreData? decode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['version'] != version) return null;
      final profile = map['profile'];
      return StoreData(
        nextId: map['nextId'] as int,
        lastCreditedPayday: switch (map['lastCreditedPayday']) {
          final String iso => DateTime.parse(iso),
          _ => null,
        },
        profile: profile == null
            ? null
            : _profileFromJson(profile as Map<String, dynamic>),
        settings: _settingsFromJson(map['settings'] as Map<String, dynamic>),
        goals: [
          for (final g in map['goals'] as List<dynamic>)
            _goalFromJson(g as Map<String, dynamic>),
        ],
        ledger: [
          for (final e in map['ledger'] as List<dynamic>)
            _expenseFromJson(e as Map<String, dynamic>),
        ],
      );
    } on Object {
      return null;
    }
  }

  // ── Money ───────────────────────────────────────────────────────────────
  static Money _money(Object? value) => Money.fromHalalas(value! as int);

  // ── Profile ─────────────────────────────────────────────────────────────
  static Map<String, Object?> _profileToJson(BudgetProfile p) => {
        'netSalary': p.netSalary.halalas,
        'payDay': p.payDay,
        'commitments': [for (final c in p.commitments) _commitmentToJson(c)],
      };

  static BudgetProfile _profileFromJson(Map<String, dynamic> json) {
    return BudgetProfile(
      netSalary: _money(json['netSalary']),
      payDay: json['payDay'] as int,
      commitments: [
        for (final c in json['commitments'] as List<dynamic>)
          _commitmentFromJson(c as Map<String, dynamic>),
      ],
    );
  }

  static Map<String, Object?> _commitmentToJson(FixedExpense c) => {
        'id': c.id,
        'title': c.title,
        'amount': c.amount.halalas,
        'category': c.category.name,
        'status': c.status.name,
        'date': c.date.toIso8601String(),
        'isAutoPay': c.isAutoPay,
      };

  static FixedExpense _commitmentFromJson(Map<String, dynamic> json) {
    return FixedExpense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: _money(json['amount']),
      category: FixedExpenseCategory.values.byName(json['category'] as String),
      status: FixedExpenseStatus.values.byName(json['status'] as String),
      date: DateTime.parse(json['date'] as String),
      isAutoPay: json['isAutoPay'] as bool,
    );
  }

  // ── Goals ───────────────────────────────────────────────────────────────
  static Map<String, Object?> _goalToJson(SavingsGoal g) => {
        'id': g.id,
        'title': g.title,
        'subtitle': g.subtitle,
        'kind': g.kind.name,
        'target': g.target.halalas,
        'saved': g.saved.halalas,
        'monthly': g.monthlyContribution.halalas,
      };

  static SavingsGoal _goalFromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      kind: GoalKind.values.byName(json['kind'] as String),
      target: _money(json['target']),
      saved: _money(json['saved']),
      monthlyContribution: _money(json['monthly']),
    );
  }

  // ── Ledger ──────────────────────────────────────────────────────────────
  static Map<String, Object?> _expenseToJson(Expense e) => {
        'id': e.id,
        'amount': e.amount.halalas,
        'createdAt': e.createdAt.toIso8601String(),
        if (e.note != null) 'note': e.note,
      };

  static Expense _expenseFromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      amount: _money(json['amount']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
    );
  }

  // ── Settings ────────────────────────────────────────────────────────────
  static Map<String, Object?> _settingsToJson(AppSettings s) => {
        'dailyLimitAlerts': s.dailyLimitAlerts,
        'officialPayoutAlerts': s.officialPayoutAlerts,
        'appearance': s.appearance.name,
        'enabledPayoutAlertIds': s.enabledPayoutAlertIds.toList()..sort(),
      };

  static AppSettings _settingsFromJson(Map<String, dynamic> json) {
    return AppSettings(
      dailyLimitAlerts: json['dailyLimitAlerts'] as bool,
      officialPayoutAlerts: json['officialPayoutAlerts'] as bool,
      // Older saves have no `appearance` (the old dark-mode flag was never
      // switchable), so they fall back to following the phone.
      appearance: AppearanceMode.fromName(json['appearance'] as String?),
      enabledPayoutAlertIds: {
        for (final id in json['enabledPayoutAlertIds'] as List<dynamic>)
          id as String,
      },
    );
  }
}
