import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/features/account/domain/account_service.dart';
import 'package:rateby/features/account/domain/cloud_backup.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/upgrade/application/billing_providers.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';

/// Overridden in `main()` where Firebase exists.
final accountServiceProvider =
    Provider<AccountService>((ref) => const NoAccountService());

final cloudBackupProvider =
    Provider<CloudBackup>((ref) => const NoCloudBackup());

/// The signed-in person, or `null` while signed out.
final accountUserProvider = StreamProvider<AccountUser?>((ref) {
  final service = ref.watch(accountServiceProvider);
  // Subscribe at once (no gap between the first value and the changes).
  final controller = StreamController<AccountUser?>()..add(service.currentUser);
  final subscription = service.changes.listen(
    controller.add,
    onError: controller.addError,
  );
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });
  return controller.stream;
});

enum BackupStatus { idle, syncing, failed }

@immutable
class BackupState {
  const BackupState({this.status = BackupStatus.idle, this.conflict});

  final BackupStatus status;

  /// Set when this phone and the account both hold data and they differ:
  /// the person must choose which one to keep.
  final CloudBackupDoc? conflict;

  BackupState copyWith({
    BackupStatus? status,
    CloudBackupDoc? conflict,
    bool clearConflict = false,
  }) =>
      BackupState(
        status: status ?? this.status,
        conflict: clearConflict ? null : conflict ?? this.conflict,
      );
}

/// Keeps the account copy of the budget data in step with the phone.
///
/// * First sign-in on a phone with no data → the account copy is restored.
/// * First sign-in with data and an empty account → this phone is uploaded.
/// * Both hold different data → [BackupState.conflict] asks the person.
/// * Afterwards every save is mirrored (a few seconds later).
/// * Signing in also refreshes the subscription, so Plus follows the account.
class BackupSyncController extends Notifier<BackupState> {
  static const Duration _debounce = Duration(seconds: 4);

  Timer? _timer;
  StreamSubscription<String>? _saves;

  @override
  BackupState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _saves?.cancel();
    });
    ref.listen<AsyncValue<AccountUser?>>(
      accountUserProvider,
      (previous, next) {
        final user = next.valueOrNull;
        final before = previous?.valueOrNull;
        if (user != null && user.uid != before?.uid) {
          unawaited(onSignedIn(user));
        }
        if (user == null) state = const BackupState();
      },
      fireImmediately: true,
    );
    _saves = ref.read(budgetStoreProvider).saved.listen(_scheduleUpload);
    return const BackupState();
  }

  AccountUser? get _user => ref.read(accountUserProvider).valueOrNull;

  /// Reconciles this phone with the account right after sign-in.
  Future<void> onSignedIn(AccountUser user) async {
    state = state.copyWith(status: BackupStatus.syncing);
    try {
      await _refreshEntitlement();
      final store = ref.read(budgetStoreProvider);
      final cloud = await ref.read(cloudBackupProvider).fetch(user.uid);
      if (cloud == null) {
        if (store.hasData) {
          await ref.read(cloudBackupProvider).push(user.uid, store.exportJson());
        }
      } else if (!store.hasData) {
        await store.importJson(cloud.payload);
      } else if (cloud.payload != store.exportJson()) {
        state = state.copyWith(status: BackupStatus.idle, conflict: cloud);
        return;
      }
      state = state.copyWith(status: BackupStatus.idle);
    } on Object {
      state = state.copyWith(status: BackupStatus.failed);
    }
  }

  Future<void> _refreshEntitlement() async {
    final verifier = ref.read(subscriptionVerifierProvider);
    if (verifier == null) return;
    try {
      final entitlement = await verifier.refresh();
      if (entitlement.active) {
        await ref.read(entitlementProvider.notifier).update(entitlement);
      }
    } on Object {
      // Offline or no subscription: the Upgrade tab can retry.
    }
  }

  /// The person chose the account copy.
  Future<void> useCloudCopy() async {
    final cloud = state.conflict;
    if (cloud == null) return;
    state = state.copyWith(status: BackupStatus.syncing, clearConflict: true);
    try {
      await ref.read(budgetStoreProvider).importJson(cloud.payload);
      state = state.copyWith(status: BackupStatus.idle);
    } on Object {
      state = state.copyWith(status: BackupStatus.failed);
    }
  }

  /// The person chose this phone's data: it replaces the account copy.
  Future<void> keepThisPhone() async {
    state = state.copyWith(clearConflict: true);
    await _upload();
  }

  void _scheduleUpload(String _) {
    if (_user == null || state.conflict != null) return;
    _timer?.cancel();
    _timer = Timer(_debounce, () => unawaited(_upload()));
  }

  Future<void> _upload() async {
    final user = _user;
    if (user == null || state.conflict != null) return;
    final store = ref.read(budgetStoreProvider);
    if (!store.hasData) return;
    try {
      await ref.read(cloudBackupProvider).push(user.uid, store.exportJson());
      if (state.status == BackupStatus.failed) {
        state = state.copyWith(status: BackupStatus.idle);
      }
    } on Object {
      state = state.copyWith(status: BackupStatus.failed);
    }
  }

  /// Deletes the account: its copy of the data first (only the signed-in
  /// person may delete it), then the account itself. The server removes the
  /// rest (subscription records). The phone's data stays.
  ///
  /// `false` when the person cancelled; throws when the deletion failed.
  Future<bool> deleteAccount() async {
    final user = _user;
    if (user == null) return true;
    _timer?.cancel();
    await ref.read(cloudBackupProvider).delete(user.uid);
    final deleted = await ref.read(accountServiceProvider).deleteAccount();
    if (deleted) await ref.read(entitlementProvider.notifier).clear();
    return deleted;
  }

  /// Deletes the account copy (the phone's data stays).
  Future<bool> deleteCloudCopy() async {
    final user = _user;
    if (user == null) return false;
    try {
      await ref.read(cloudBackupProvider).delete(user.uid);
      return true;
    } on Object {
      return false;
    }
  }
}

final backupSyncProvider =
    NotifierProvider<BackupSyncController, BackupState>(BackupSyncController.new);
