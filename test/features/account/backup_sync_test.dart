import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/account/application/account_providers.dart';
import 'package:rateby/features/account/domain/account_service.dart';
import 'package:rateby/features/account/domain/cloud_backup.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/upgrade/application/billing_providers.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';
import 'package:rateby/features/upgrade/domain/plus_entitlement.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';
import 'package:rateby/features/upgrade/domain/subscription_verifier.dart';

import '../../support/test_overrides.dart';

class FakeAccount implements AccountService {
  final _changes = StreamController<AccountUser?>.broadcast();
  AccountUser? _user;

  void emit(AccountUser? user) {
    _user = user;
    _changes.add(user);
  }

  @override
  AccountUser? get currentUser => _user;
  @override
  Stream<AccountUser?> get changes => _changes.stream;
  @override
  Future<AccountUser?> signInWithGoogle() async => _user;
  @override
  Future<void> signOut() async => emit(null);
}

class FakeCloud implements CloudBackup {
  final Map<String, CloudBackupDoc> docs = {};
  int pushes = 0;

  @override
  Future<CloudBackupDoc?> fetch(String uid) async => docs[uid];
  @override
  Future<void> push(String uid, String payload) async {
    pushes++;
    docs[uid] = CloudBackupDoc(payload: payload, updatedAt: DateTime(2026));
  }

  @override
  Future<void> delete(String uid) async => docs.remove(uid);
}

class FakeVerifier implements SubscriptionVerifier {
  FakeVerifier(this.entitlement);
  final PlusEntitlement entitlement;
  int refreshes = 0;

  @override
  Future<PlusEntitlement> refresh() async {
    refreshes++;
    return entitlement;
  }

  @override
  Future<PlusEntitlement> verify({
    required String productId,
    required String purchaseToken,
  }) async =>
      entitlement;
}

const user = AccountUser(uid: 'u1', email: 'a@b.c');

ProviderContainer make({
  required FakeAccount account,
  required FakeCloud cloud,
  required Override store,
  FakeVerifier? verifier,
}) {
  final container = ProviderContainer(
    overrides: [
      fixedClock(),
      store,
      accountServiceProvider.overrideWithValue(account),
      cloudBackupProvider.overrideWithValue(cloud),
      if (verifier != null) subscriptionVerifierProvider.overrideWithValue(verifier),
    ],
  );
  addTearDown(container.dispose);
  container.listen(backupSyncProvider, (_, __) {});
  return container;
}

void main() {
  test('a new phone gets the data saved in the account', () async {
    final cloud = FakeCloud();
    // Another phone had the demo data.
    final source = make(account: FakeAccount(), cloud: cloud, store: demoStore());
    cloud.docs['u1'] = CloudBackupDoc(
      payload: source.read(budgetStoreProvider).exportJson(),
      updatedAt: DateTime(2026),
    );

    final account = FakeAccount();
    final fresh = make(account: account, cloud: cloud, store: emptyStore());
    expect(fresh.read(budgetStoreProvider).hasData, isFalse);

    account.emit(user);
    await pumpEventQueue();

    expect(fresh.read(budgetStoreProvider).hasData, isTrue);
    expect((await fresh.read(profileProvider.future))?.netSalary, Money.fromRiyals(12000));
  });

  test('first sign-in uploads this phone when the account is empty', () async {
    final cloud = FakeCloud();
    final account = FakeAccount();
    make(account: account, cloud: cloud, store: demoStore());

    account.emit(user);
    await pumpEventQueue();

    expect(cloud.docs['u1'], isNotNull);
    expect(cloud.pushes, 1);
  });

  test('different data on phone and account asks which to keep', () async {
    final cloud = FakeCloud()
      ..docs['u1'] = CloudBackupDoc(payload: 'not the same', updatedAt: DateTime(2026));
    final account = FakeAccount();
    final container = make(account: account, cloud: cloud, store: demoStore());

    account.emit(user);
    await pumpEventQueue();
    expect(container.read(backupSyncProvider).conflict, isNotNull);
    expect(cloud.pushes, 0, reason: 'nothing is overwritten before the choice');

    await container.read(backupSyncProvider.notifier).keepThisPhone();
    expect(container.read(backupSyncProvider).conflict, isNull);
    expect(cloud.pushes, 1);
  });

  test('choosing the account copy replaces this phone', () async {
    final cloudSource = make(
      account: FakeAccount(),
      cloud: FakeCloud(),
      store: demoStore(),
    );
    final cloud = FakeCloud()
      ..docs['u1'] = CloudBackupDoc(
        payload: cloudSource.read(budgetStoreProvider).exportJson(),
        updatedAt: DateTime(2026),
      );
    final account = FakeAccount();
    final container = make(account: account, cloud: cloud, store: demoStore());
    // Make the phone differ from the account.
    await container.read(budgetRepositoryProvider).logExpense(Money.fromRiyals(5));

    account.emit(user);
    await pumpEventQueue();
    expect(container.read(backupSyncProvider).conflict, isNotNull);

    await container.read(backupSyncProvider.notifier).useCloudCopy();
    expect(container.read(backupSyncProvider).conflict, isNull);
    expect(
      container.read(budgetStoreProvider).exportJson(),
      cloud.docs['u1']!.payload,
    );
  });

  test('signing in brings the subscription back', () async {
    final verifier = FakeVerifier(
      const PlusEntitlement(active: true, plan: PlusPlanType.yearly),
    );
    final account = FakeAccount();
    final container = make(
      account: account,
      cloud: FakeCloud(),
      store: emptyStore(),
      verifier: verifier,
    );
    expect(container.read(isPlusProvider), isFalse);

    account.emit(user);
    await pumpEventQueue();

    expect(verifier.refreshes, 1);
    expect(container.read(isPlusProvider), isTrue);
  });

  test('nothing is uploaded while signed out', () async {
    final cloud = FakeCloud();
    final container = make(account: FakeAccount(), cloud: cloud, store: demoStore());
    await container.read(budgetRepositoryProvider).logExpense(Money.fromRiyals(5));
    await pumpEventQueue();
    expect(cloud.pushes, 0);
  });

  test('a backup that is not valid is refused and changes nothing', () async {
    final container = make(account: FakeAccount(), cloud: FakeCloud(), store: demoStore());
    final store = container.read(budgetStoreProvider);
    final before = store.exportJson();
    expect(await store.importJson('{broken'), isFalse);
    expect(store.exportJson(), before);
  });
}
