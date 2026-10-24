import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/onboarding/application/onboarding_controller.dart';
import 'package:rateby/features/onboarding/application/onboarding_state.dart';

import '../../support/test_overrides.dart';

ProviderContainer makeContainer() {
  final container = ProviderContainer(overrides: [fixedClock(), emptyStore()]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('starts on the salary step; continue needs a salary', () {
    final container = makeContainer();
    container.listen(onboardingControllerProvider, (_, __) {});

    var state = container.read(onboardingControllerProvider);
    expect(state.step, OnboardingStep.salary);
    expect(state.canContinue, isFalse);

    container.read(onboardingControllerProvider.notifier)
      ..next() // ignored: no salary yet
      ..setSalary(Money.fromRiyals(12000));
    state = container.read(onboardingControllerProvider);
    expect(state.step, OnboardingStep.salary);
    expect(state.canContinue, isTrue);
  });

  test('steps move forward and back, and stop at both ends', () {
    final container = makeContainer();
    container.listen(onboardingControllerProvider, (_, __) {});
    final controller = container.read(onboardingControllerProvider.notifier)
      ..back() // already first
      ..setSalary(Money.fromRiyals(9000))
      ..next();
    expect(
      container.read(onboardingControllerProvider).step,
      OnboardingStep.commitments,
    );

    controller
      ..next()
      ..next(); // already last
    expect(
      container.read(onboardingControllerProvider).step,
      OnboardingStep.payday,
    );

    controller.back();
    expect(
      container.read(onboardingControllerProvider).step,
      OnboardingStep.commitments,
    );
  });

  test('commitments can be removed and added; the total follows', () {
    final container = makeContainer();
    container.listen(onboardingControllerProvider, (_, __) {});
    final controller = container.read(onboardingControllerProvider.notifier);

    expect(
      container.read(onboardingControllerProvider).commitmentsTotal,
      Money.fromRiyals(3450),
    );

    controller.removeCommitmentAt(0); // car finance 1,850
    expect(
      container.read(onboardingControllerProvider).commitmentsTotal,
      Money.fromRiyals(1600),
    );

    controller.addCommitment(
      CommitmentDraft(
        title: 'اشتراك',
        amount: Money.fromRiyals(50),
        category: FixedExpenseCategory.utilities,
      ),
    );
    expect(
      container.read(onboardingControllerProvider).commitmentsTotal,
      Money.fromRiyals(1650),
    );
  });

  test('summary previews the daily limit for the chosen payday', () {
    final container = makeContainer();
    container.listen(onboardingSummaryProvider, (_, __) {});
    container.read(onboardingControllerProvider.notifier)
        .setSalary(Money.fromRiyals(12000));

    // Thursday 22 Oct, payday 27 → cycle 27 Sep–27 Oct = 30 days.
    final summary = container.read(onboardingSummaryProvider);
    expect(summary.commitmentsTotal, Money.fromRiyals(3450));
    expect(summary.dailyLimit, Money.fromRiyals(285)); // 8,550 ÷ 30
    expect(summary.daysUntilPayday, 5);
  });

  test('complete() stores the profile that the rest of the app reads',
      () async {
    final container = makeContainer();
    container.listen(onboardingControllerProvider, (_, __) {});
    container.listen(profileProvider, (_, __) {});
    expect(await container.read(profileProvider.future), isNull);

    final controller = container.read(onboardingControllerProvider.notifier)
      ..setSalary(Money.fromRiyals(12000))
      ..next()
      ..next()
      ..setPayDay(25);
    await controller.complete();
    await settle();

    final profile = await container.read(profileProvider.future);
    expect(profile, isNotNull);
    expect(profile!.netSalary, Money.fromRiyals(12000));
    expect(profile.payDay, 25);
    expect(profile.commitments, hasLength(3));
    expect(profile.commitmentsTotal, Money.fromRiyals(3450));
    expect(
      profile.commitments.every((c) => c.status == FixedExpenseStatus.scheduled),
      isTrue,
    );
  });

  test('complete() does nothing before the last step', () async {
    final container = makeContainer();
    container.listen(profileProvider, (_, __) {});
    container.read(onboardingControllerProvider.notifier)
        .setSalary(Money.fromRiyals(12000));

    await container.read(onboardingControllerProvider.notifier).complete();
    await settle();
    expect(await container.read(profileProvider.future), isNull);
  });
}
