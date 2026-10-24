import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/providers/clock_provider.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/home/application/home_state.dart';
import 'package:rateby/features/profile/application/user_profile_provider.dart';

/// Turns the shared budget stream into [HomeState] and owns Home's actions.
///
/// The screen watches this provider; it never touches repositories or does
/// date / money math itself.
class HomeController extends AsyncNotifier<HomeState> {
  /// Hour (24h clock) at which the greeting switches to "good evening".
  static const int _eveningStartsAtHour = 12;

  @override
  Future<HomeState> build() async {
    // Read synchronous dependencies before the first `await`.
    final profile = ref.watch(userProfileProvider);
    final now = ref.watch(clockProvider)();
    final snapshot = await ref.watch(budgetSnapshotProvider.future);

    return HomeState(
      userName: profile.displayName,
      today: now,
      greeting: now.hour < _eveningStartsAtHour
          ? HomeGreeting.morning
          : HomeGreeting.evening,
      allowance: snapshot.allowance,
      health: snapshot.allowance.health,
      salaryCycle: snapshot.salaryCycle,
      fixedExpenses: snapshot.fixedExpenses,
      fixedExpensesPaidTotal: snapshot.paidFixedExpensesTotal,
      fixedExpensesTotal: snapshot.monthlyCommitmentsTotal,
    );
  }

  /// Pull-to-refresh: re-subscribes to the data source and waits for it.
  Future<void> refresh() async {
    ref.invalidate(budgetSnapshotProvider);
    await ref.read(homeControllerProvider.future);
  }
}

final homeControllerProvider =
    AsyncNotifierProvider<HomeController, HomeState>(HomeController.new);
