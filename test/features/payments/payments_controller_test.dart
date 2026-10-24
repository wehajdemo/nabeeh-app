import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/features/payments/application/payments_controller.dart';
import 'package:rateby/features/payments/application/payments_state.dart';
import 'package:rateby/features/payments/application/payout_schedule_providers.dart';
import 'package:rateby/features/payments/domain/payout_info.dart';
import 'package:rateby/features/payments/domain/payout_schedule.dart';

import '../../support/fake_payout_source.dart';
import '../../support/test_overrides.dart';

ProviderContainer makeContainer() {
  final container = ProviderContainer(overrides: [fixedClock(), demoStore()]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('lists every program and filters by tab', () async {
    final container = makeContainer();
    container.listen(paymentsControllerProvider, (_, __) {});
    final state = await container.read(paymentsControllerProvider.future);

    expect(state.totalCount, 5);
    expect(state.visible(PayoutFilter.all), hasLength(5));
    expect(state.visible(PayoutFilter.government), hasLength(1));
    expect(state.visible(PayoutFilter.support), hasLength(2));
    expect(state.visible(PayoutFilter.retireesAndStudents), hasLength(2));
  });

  test('highlights the nearest upcoming payout, skipping paid ones', () async {
    final container = makeContainer();
    container.listen(paymentsControllerProvider, (_, __) {});
    final state = await container.read(paymentsControllerProvider.future);

    // On Thursday 22 Oct: student stipends window opens in 3 days — before
    // the 27th (5 days); citizen account is already paid.
    expect(state.nextDueId(PayoutFilter.all), 'student-stipends');
    expect(state.nextDueId(PayoutFilter.government), 'gov-salaries');
    final citizen = state.items.firstWhere((i) => i.id == 'citizen-account');
    expect(citizen.info.status, PayoutStatus.paid);
  });

  test('the alert toggle turns a reminder on and off', () async {
    final container = makeContainer();
    container.listen(paymentsControllerProvider, (_, __) {});
    var state = await container.read(paymentsControllerProvider.future);
    expect(state.items.any((i) => i.alertEnabled), isFalse);

    final controller = container.read(paymentsControllerProvider.notifier);
    await controller.toggleAlert('gov-salaries');
    await settle();
    state = await container.read(paymentsControllerProvider.future);
    expect(
      state.items.firstWhere((i) => i.id == 'gov-salaries').alertEnabled,
      isTrue,
    );

    await controller.toggleAlert('gov-salaries');
    await settle();
    state = await container.read(paymentsControllerProvider.future);
    expect(state.items.any((i) => i.alertEnabled), isFalse);
  });

  test('the selected filter is kept in its own provider', () {
    final container = makeContainer();
    container.listen(payoutFilterProvider, (_, __) {});
    expect(container.read(payoutFilterProvider), PayoutFilter.all);
    container.read(payoutFilterProvider.notifier).select(PayoutFilter.support);
    expect(container.read(payoutFilterProvider), PayoutFilter.support);
  });

  test('uses the built-in catalog when nothing was published', () async {
    final container = makeContainer();
    container.listen(paymentsControllerProvider, (_, __) {});
    final state = await container.read(paymentsControllerProvider.future);

    expect(state.scheduleSource, PayoutScheduleSource.catalog);
    expect(state.scheduleUpdatedAt, isNull);
  });

  test('shows the schedule published from the dashboard', () async {
    final remote = FakePayoutSource(
      doc: scheduleDoc(
        [programDoc(id: 'live-1', day: 5), programDoc(id: 'live-2', day: 20)],
        updatedAt: 1760000000000,
      ),
    );
    final container = ProviderContainer(overrides: [
      fixedClock(),
      demoStore(),
      payoutRemoteSourceProvider.overrideWithValue(remote),
    ]);
    addTearDown(container.dispose);
    container.listen(paymentsControllerProvider, (_, __) {});
    await container.read(paymentsControllerProvider.future);
    await settle();

    final state = await container.read(paymentsControllerProvider.future);

    expect(state.items.map((i) => i.id), ['live-1', 'live-2']);
    expect(state.scheduleSource, PayoutScheduleSource.remote);
    expect(
      state.scheduleUpdatedAt,
      DateTime.fromMillisecondsSinceEpoch(1760000000000),
    );
  });
}
