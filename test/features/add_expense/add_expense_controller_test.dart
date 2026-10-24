import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/add_expense/application/add_expense_controller.dart';
import 'package:rateby/features/add_expense/application/add_expense_view_state.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import '../../support/test_overrides.dart';

ProviderContainer makeContainer() {
  final container = ProviderContainer(
    overrides: [fixedClock(), demoStore()],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('typing updates the view state and the live deduction hint', () async {
    final container = makeContainer();
    container.listen(budgetSnapshotProvider, (_, __) {});
    container.listen(addExpenseViewStateProvider, (_, __) {});
    await container.read(budgetSnapshotProvider.future);

    final controller = container.read(addExpenseControllerProvider.notifier);
    expect(
      container.read(addExpenseViewStateProvider).hint,
      AmountHint.prompt,
    );

    controller
      ..pressDigit('1')
      ..pressDigit('2');
    final view = container.read(addExpenseViewStateProvider);
    expect(view.amountText, '12');
    expect(view.hint, AmountHint.deduct);
    expect(view.hintAmount, Money.fromRiyals(12));
    expect(view.remaining, Money.fromRiyals(198)); // 221 limit − 23 spent
  });

  test('an amount above the remaining limit is flagged, not blocked', () async {
    final container = makeContainer();
    container.listen(budgetSnapshotProvider, (_, __) {});
    container.listen(addExpenseViewStateProvider, (_, __) {});
    await container.read(budgetSnapshotProvider.future);

    container.read(addExpenseControllerProvider.notifier).selectPreset(500);
    final view = container.read(addExpenseViewStateProvider);
    expect(view.hint, AmountHint.overLimit);
    expect(view.hintAmount, Money.fromRiyals(302)); // 500 − 198
  });

  test('saving zero shows a validation error and logs nothing', () async {
    final container = makeContainer();
    container.listen(budgetSnapshotProvider, (_, __) {});
    container.listen(addExpenseViewStateProvider, (_, __) {});
    await container.read(budgetSnapshotProvider.future);

    await container.read(addExpenseControllerProvider.notifier).save();
    expect(
      container.read(addExpenseViewStateProvider).hint,
      AmountHint.invalid,
    );
    final snapshot = await container.read(budgetSnapshotProvider.future);
    expect(snapshot.allowance.spentToday, Money.fromRiyals(23));
  });

  test('saving deducts from today and resets the keypad', () async {
    final container = makeContainer();
    container.listen(budgetSnapshotProvider, (_, __) {});
    container.listen(addExpenseViewStateProvider, (_, __) {});
    await container.read(budgetSnapshotProvider.future);

    final controller = container.read(addExpenseControllerProvider.notifier)
      ..selectPreset(20);
    await controller.save();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final view = container.read(addExpenseViewStateProvider);
    expect(view.amountText, '0');
    expect(view.savedAmount, Money.fromRiyals(20));
    expect(view.remaining, Money.fromRiyals(178)); // 198 − 20
  });
}
