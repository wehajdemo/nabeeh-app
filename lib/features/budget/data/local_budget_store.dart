import 'dart:async';

import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/utils/date_math.dart';
import 'package:rateby/features/budget/data/budget_storage.dart';
import 'package:rateby/features/budget/data/store_data_codec.dart';
import 'package:rateby/features/budget/domain/entities/app_settings.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/budget/domain/entities/budget_snapshot.dart';
import 'package:rateby/features/budget/domain/entities/daily_allowance.dart';
import 'package:rateby/features/budget/domain/entities/expense.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/budget/domain/entities/salary_cycle.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';
import 'package:rateby/features/budget/domain/repositories/budget_repository.dart';
import 'package:rateby/features/budget/domain/repositories/goals_repository.dart';
import 'package:rateby/features/budget/domain/repositories/profile_repository.dart';
import 'package:rateby/features/budget/domain/repositories/settings_repository.dart';
import 'package:rateby/features/budget/domain/services/daily_limit_calculator.dart';
import 'package:rateby/features/budget/domain/services/goal_payday_crediting.dart';

/// Local data source implementing every repository contract.
///
/// State lives in memory and is mirrored to a [BudgetStorage] after each
/// change, then restored on the next launch. Starts empty (first run →
/// onboarding). Use [LocalBudgetStore.demo] for a pre-populated store.
/// Replace with Drift / Isar / REST implementations of the same interfaces;
/// nothing above the data layer needs to change.
class LocalBudgetStore
    implements
        BudgetRepository,
        ProfileRepository,
        GoalsRepository,
        SettingsRepository {
  LocalBudgetStore({
    required DateTime Function() clock,
    this.storage,
    this.latency = Duration.zero,
  }) : _clock = clock {
    _restore();
  }

  /// Store pre-filled with the numbers used in the design mock-ups.
  factory LocalBudgetStore.demo({
    required DateTime Function() clock,
    Duration latency = const Duration(milliseconds: 120),
  }) {
    final store = LocalBudgetStore(clock: clock, latency: latency);
    final now = clock();
    final cycle = SalaryCycle.forPayDay(payDay: 27, today: now);
    FixedExpense commitment(
      String id,
      String title,
      int riyals,
      FixedExpenseCategory category,
    ) {
      return FixedExpense.scheduled(
        id: id,
        title: title,
        amount: Money.fromRiyals(riyals),
        category: category,
        date: cycle.nextPayday,
      );
    }

    store
      .._profile = BudgetProfile(
        netSalary: Money.fromRiyals(12000),
        payDay: 27,
        commitments: [
          commitment(
            'car',
            AppStrings.carFinance,
            1850,
            FixedExpenseCategory.carFinance,
          ),
          commitment(
            'bnpl',
            AppStrings.bnpl,
            620,
            FixedExpenseCategory.buyNowPayLater,
          ),
          commitment(
            'utilities',
            AppStrings.utilities,
            980,
            FixedExpenseCategory.utilities,
          ),
        ],
      )
      .._goals.addAll([
        SavingsGoal(
          id: 'emergency',
          title: AppStrings.goalEmergency,
          subtitle: AppStrings.goalEmergencyNote,
          kind: GoalKind.emergency,
          target: Money.fromRiyals(10000),
          saved: Money.fromRiyals(4500),
          monthlyContribution: Money.fromRiyals(500),
        ),
        SavingsGoal(
          id: 'travel',
          title: AppStrings.goalTravel,
          subtitle: AppStrings.goalTravelNote,
          kind: GoalKind.travel,
          target: Money.fromRiyals(5000),
          saved: Money.fromRiyals(3200),
          monthlyContribution: Money.fromRiyals(400),
        ),
        SavingsGoal(
          id: 'car',
          title: AppStrings.goalCar,
          subtitle: AppStrings.goalCarNote,
          kind: GoalKind.car,
          target: Money.fromRiyals(30000),
          saved: Money.fromRiyals(12000),
          monthlyContribution: Money.fromRiyals(1000),
        ),
      ])
      .._ledger.add(
        Expense(id: 'seed-1', amount: Money.fromRiyals(23), createdAt: now),
      )
      .._lastCreditedPayday = cycle.previousPayday;
    return store;
  }

  final DateTime Function() _clock;

  /// Where state is persisted; `null` keeps everything in memory only.
  final BudgetStorage? storage;

  /// Optional artificial delay, to exercise loading / saving states.
  final Duration latency;

  /// Expenses older than this are dropped when saving (only today's spending
  /// affects the daily limit).
  static const Duration _ledgerRetention = Duration(days: 62);

  BudgetProfile? _profile;
  AppSettings _settings = const AppSettings();
  final List<SavingsGoal> _goals = [];
  final List<Expense> _ledger = [];
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int _nextId = 0;

  /// The payday up to which goal contributions have been credited.
  DateTime? _lastCreditedPayday;

  void dispose() {
    _changes.close();
    _saved.close();
  }

  // ── Streams ─────────────────────────────────────────────────────────────

  /// Emits `read()` immediately on listen, then after every change.
  Stream<T> _watch<T>(T Function() read) {
    late final StreamController<T> controller;
    StreamSubscription<void>? subscription;

    controller = StreamController<T>(
      onListen: () {
        controller.add(read());
        subscription = _changes.stream.listen((_) => controller.add(read()));
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  Future<void> _commit(void Function() mutate) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    mutate();
    if (!_changes.isClosed) _changes.add(null);
    await _persist();
  }

  void _restore() {
    final raw = storage?.read();
    if (raw == null) return;
    final data = StoreDataCodec.decode(raw);
    if (data == null) return;
    _profile = data.profile;
    _settings = data.settings;
    _goals
      ..clear()
      ..addAll(data.goals);
    _ledger
      ..clear()
      ..addAll(data.ledger);
    _nextId = data.nextId;
    _lastCreditedPayday = data.lastCreditedPayday;
  }

  Future<void> _persist() async {
    final target = storage;
    if (target == null) return;
    final cutoff = _clock().subtract(_ledgerRetention);
    _ledger.removeWhere((e) => e.createdAt.isBefore(cutoff));
    final raw = exportJson();
    await target.write(raw);
    if (!_saved.isClosed) _saved.add(raw);
  }


  // ── Backup (cloud copy and manual restore) ──────────────────────────────

  final StreamController<String> _saved = StreamController<String>.broadcast();

  /// The serialized state after every successful save. Used to mirror the
  /// data to the user's account when they are signed in.
  Stream<String> get saved => _saved.stream;

  /// `true` once onboarding is done, i.e. there is something worth backing up.
  bool get hasData => _profile != null;

  /// The current state as the same JSON that is stored on the device.
  String exportJson() => StoreDataCodec.encode(
        StoreData(
          profile: _profile,
          settings: _settings,
          goals: List.of(_goals),
          ledger: List.of(_ledger),
          nextId: _nextId,
          lastCreditedPayday: _lastCreditedPayday,
        ),
      );

  /// Replaces everything with [raw] (a backup made by [exportJson]).
  /// Returns `false`, changing nothing, if [raw] is not a valid backup.
  Future<bool> importJson(String raw) async {
    final data = StoreDataCodec.decode(raw);
    if (data == null) return false;
    _profile = data.profile;
    _settings = data.settings;
    _goals
      ..clear()
      ..addAll(data.goals);
    _ledger
      ..clear()
      ..addAll(data.ledger);
    _nextId = data.nextId;
    _lastCreditedPayday = data.lastCreditedPayday;
    if (!_changes.isClosed) _changes.add(null);
    await _persist();
    return true;
  }

  String _newId(String prefix) => '$prefix-${_nextId++}';

  // ── BudgetRepository ────────────────────────────────────────────────────

  @override
  Stream<BudgetSnapshot> watchSnapshot() => _watch(_buildSnapshot);

  @override
  Future<void> logExpense(Money amount, {String? note}) => _commit(() {
        _ledger.add(
          Expense(
            id: _newId('expense'),
            amount: amount,
            createdAt: _clock(),
            note: note,
          ),
        );
      });

  @override
  Future<List<Expense>> loadExpenses() async {
    final sorted = List<Expense>.of(_ledger)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return List.unmodifiable(sorted);
  }

  BudgetSnapshot _buildSnapshot() {
    final now = _clock();
    final profile = _profile ?? BudgetProfile.empty;
    final cycle = SalaryCycle.forPayDay(
      payDay: profile.payDay,
      today: DateMath.dateOnly(now),
    );

    final spentToday = _ledger
        .where((e) => DateMath.isSameDay(e.createdAt, now))
        .fold(const Money.zero(), (sum, e) => sum + e.amount);

    final dailyLimit = DailyLimitCalculator.calculate(
      netSalary: profile.netSalary,
      commitmentsTotal: profile.commitmentsTotal,
      monthlyGoalsTotal: _goalsMonthlyTotal(),
      cycleLengthDays: cycle.lengthInDays,
    );

    return BudgetSnapshot(
      allowance: DailyAllowance(dailyLimit: dailyLimit, spentToday: spentToday),
      salaryCycle: cycle,
      fixedExpenses: List.unmodifiable(profile.commitments),
      monthlyCommitmentsTotal: profile.commitmentsTotal,
    );
  }

  Money _goalsMonthlyTotal() => _goals.fold(
        const Money.zero(),
        (sum, g) => sum + g.effectiveMonthly,
      );

  /// Marks every payday up to today as already handled, so changing the
  /// set-up never credits goals retroactively.
  DateTime _latestPayday(BudgetProfile profile) => GoalPaydayCrediting.latestPayday(
        payDay: profile.payDay,
        today: DateMath.dateOnly(_clock()),
      );

  // ── ProfileRepository ───────────────────────────────────────────────────

  @override
  Stream<BudgetProfile?> watchProfile() => _watch(() => _profile);

  @override
  Future<void> completeSetup(BudgetProfile profile) => _commit(() {
        _profile = profile;
        _lastCreditedPayday = _latestPayday(profile);
      });

  @override
  Future<void> updateNetSalary(Money salary) => _commit(() {
        final profile = _profile ?? BudgetProfile.empty;
        _profile = profile.copyWith(netSalary: salary);
      });

  @override
  Future<void> updatePayDay(int day) => _commit(() {
        final profile = _profile ?? BudgetProfile.empty;
        final updated = profile.copyWith(payDay: day);
        _profile = updated;
        _lastCreditedPayday = _latestPayday(updated);
      });

  @override
  Future<void> addCommitment(CommitmentDraft draft) => _commit(() {
        final profile = _profile ?? BudgetProfile.empty;
        final cycle = SalaryCycle.forPayDay(
          payDay: profile.payDay,
          today: DateMath.dateOnly(_clock()),
        );
        _profile = profile.copyWith(
          commitments: [
            ...profile.commitments,
            FixedExpense.scheduled(
              id: _newId('commitment'),
              title: draft.title,
              amount: draft.amount,
              category: draft.category,
              date: cycle.nextPayday,
            ),
          ],
        );
      });

  @override
  Future<void> removeCommitment(String id) => _commit(() {
        final profile = _profile;
        if (profile == null) return;
        _profile = profile.copyWith(
          commitments:
              profile.commitments.where((c) => c.id != id).toList(),
        );
      });

  @override
  Future<void> resetAll() => _commit(() {
        _profile = null;
        _goals.clear();
        _ledger.clear();
        _lastCreditedPayday = null;
        _settings = const AppSettings();
      });

  // ── GoalsRepository ─────────────────────────────────────────────────────

  @override
  Stream<List<SavingsGoal>> watchGoals() =>
      _watch(() => List<SavingsGoal>.unmodifiable(_goals));

  @override
  Future<void> addGoal(GoalDraft draft) => _commit(() {
        _goals.add(
          SavingsGoal(
            id: _newId('goal'),
            title: draft.title,
            target: draft.target,
            saved: const Money.zero(),
            monthlyContribution: draft.monthlyContribution,
          ),
        );
      });

  @override
  Future<void> updateGoal(String id, GoalDraft draft) => _commit(() {
        final index = _goals.indexWhere((g) => g.id == id);
        if (index < 0) return;
        _goals[index] = _goals[index].copyWith(
          title: draft.title,
          target: draft.target,
          monthlyContribution: draft.monthlyContribution,
        );
      });

  @override
  Future<void> deposit(String id, Money amount) => _commit(() {
        if (!amount.isPositive) return;
        final index = _goals.indexWhere((g) => g.id == id);
        if (index < 0) return;
        _goals[index] = _goals[index].copyWith(saved: _goals[index].saved + amount);
      });

  @override
  Future<void> withdraw(String id, Money amount) => _commit(() {
        if (!amount.isPositive) return;
        final index = _goals.indexWhere((g) => g.id == id);
        if (index < 0) return;
        _goals[index] = _goals[index].copyWith(
          saved: (_goals[index].saved - amount).clampNonNegative(),
        );
      });

  @override
  Future<int> creditDuePaydays() async {
    final profile = _profile;
    if (profile == null) return 0;

    final last = _lastCreditedPayday;
    if (last == null) {
      // Data saved before this feature existed: start counting from now.
      await _commit(() => _lastCreditedPayday = _latestPayday(profile));
      return 0;
    }

    final result = GoalPaydayCrediting.credit(
      goals: List.of(_goals),
      lastCredited: last,
      payDay: profile.payDay,
      today: DateMath.dateOnly(_clock()),
    );
    if (result.paydays == 0) return 0;
    await _commit(() {
      _goals
        ..clear()
        ..addAll(result.goals);
      _lastCreditedPayday = result.lastCredited;
    });
    return result.paydays;
  }

  // ── SettingsRepository ──────────────────────────────────────────────────

  @override
  Stream<AppSettings> watchSettings() => _watch(() => _settings);

  @override
  Future<void> saveSettings(AppSettings settings) =>
      _commit(() => _settings = settings);
}
