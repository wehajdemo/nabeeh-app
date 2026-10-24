import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/navigation/navigation_controller.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/add_expense/presentation/add_expense_screen.dart';
import 'package:rateby/features/home/application/home_controller.dart';
import 'package:rateby/features/home/presentation/widgets/home_body.dart';

/// Main dashboard. Thin by design: it maps the controller's [AsyncValue] to
/// loading / error / content and wires callbacks — nothing else.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeControllerProvider);

    return home.when(
      // Keep showing the previous data while the stream re-emits.
      skipLoadingOnReload: true,
      loading: () => const LoadingView(),
      error: (error, stackTrace) => ErrorRetryView(
        onRetry: () => ref.invalidate(homeControllerProvider),
      ),
      data: (state) => HomeBody(
        state: state,
        onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
        onLogExpense: () =>
            Navigator.of(context).push(AddExpenseScreen.route()),
        onUpgrade: () => ref
            .read(navigationControllerProvider.notifier)
            .select(AppTab.upgrade),
      ),
    );
  }
}
