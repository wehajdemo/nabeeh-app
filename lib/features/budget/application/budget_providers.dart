import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/providers/clock_provider.dart';
import 'package:rateby/features/budget/data/budget_storage.dart';
import 'package:rateby/features/budget/data/local_budget_store.dart';
import 'package:rateby/features/budget/domain/entities/app_settings.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/budget/domain/entities/budget_snapshot.dart';
import 'package:rateby/features/budget/domain/entities/daily_allowance.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';
import 'package:rateby/features/budget/domain/repositories/budget_repository.dart';
import 'package:rateby/features/budget/domain/repositories/goals_repository.dart';
import 'package:rateby/features/budget/domain/repositories/profile_repository.dart';
import 'package:rateby/features/budget/domain/repositories/settings_repository.dart';
import 'package:rateby/features/budget/domain/usecases/log_expense.dart';

/// Where data is persisted. `main()` overrides this with the on-device
/// storage; `null` (default, used by tests) keeps data in memory only.
final budgetStorageProvider = Provider<BudgetStorage?>((ref) => null);

/// Dependency-injection root. Swap the store here (or with `overrideWith`
/// in tests) — every feature depends only on the repository interfaces.
final budgetStoreProvider = Provider<LocalBudgetStore>((ref) {
  final store = LocalBudgetStore(
    clock: ref.watch(clockProvider),
    storage: ref.watch(budgetStorageProvider),
  );
  ref.onDispose(store.dispose);
  return store;
});

final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => ref.watch(budgetStoreProvider),
);
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ref.watch(budgetStoreProvider),
);
final goalsRepositoryProvider = Provider<GoalsRepository>(
  (ref) => ref.watch(budgetStoreProvider),
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => ref.watch(budgetStoreProvider),
);

final logExpenseUseCaseProvider = Provider<LogExpense>(
  (ref) => LogExpense(ref.watch(budgetRepositoryProvider)),
);

// ── Live data (shared by every feature) ───────────────────────────────────

final budgetSnapshotProvider = StreamProvider<BudgetSnapshot>(
  (ref) => ref.watch(budgetRepositoryProvider).watchSnapshot(),
);

/// `null` data means onboarding has not been completed.
final profileProvider = StreamProvider<BudgetProfile?>(
  (ref) => ref.watch(profileRepositoryProvider).watchProfile(),
);

final goalsProvider = StreamProvider<List<SavingsGoal>>(
  (ref) => ref.watch(goalsRepositoryProvider).watchGoals(),
);

final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watchSettings(),
);

/// Narrow slice for features that only care about today's allowance.
final dailyAllowanceProvider = Provider<AsyncValue<DailyAllowance>>(
  (ref) => ref.watch(budgetSnapshotProvider).whenData((s) => s.allowance),
);
