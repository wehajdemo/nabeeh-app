import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/providers/clock_provider.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/budget/data/budget_storage.dart';
import 'package:rateby/features/budget/data/local_budget_store.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';
import 'package:rateby/features/upgrade/domain/entitlement_cache.dart';
import 'package:rateby/features/upgrade/domain/plus_entitlement.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';

/// Thursday 22 Oct 2026, 17:00 — the "today" used across the test-suite.
final DateTime testNow = DateTime(2026, 10, 22, 17);

Override fixedClock([DateTime? now]) =>
    clockProvider.overrideWithValue(() => now ?? testNow);

/// Store pre-filled with the design's demo data and no artificial delay.
///
/// Demo numbers on [testNow]: salary 12,000, commitments 3,450, goals 1,900
/// per month, 30-day cycle → daily limit 221, 23 already spent → 198 left.
Override demoStore() => budgetStoreProvider.overrideWith((ref) {
      final store = LocalBudgetStore.demo(
        clock: ref.watch(clockProvider),
        latency: Duration.zero,
      );
      ref.onDispose(store.dispose);
      return store;
    });

/// Empty store (first run → onboarding), optionally backed by [storage].
Override emptyStore([BudgetStorage? storage]) =>
    budgetStoreProvider.overrideWith((ref) {
      final store = LocalBudgetStore(
        clock: ref.watch(clockProvider),
        storage: storage,
      );
      ref.onDispose(store.dispose);
      return store;
    });

/// Lets pending stream events and provider rebuilds run after a mutation.
///
/// The store notifies through broadcast streams, which deliver on later
/// microtasks, so tests wait a beat before reading derived providers.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

/// The user has an active "نبيه بلس" subscription (no end date).
Override plusActive() => entitlementCacheProvider.overrideWithValue(
      MemoryEntitlementCache(
        const PlusEntitlement(active: true, plan: PlusPlanType.yearly),
      ),
    );
