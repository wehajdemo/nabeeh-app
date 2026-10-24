import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/features/goals/application/goals_controller.dart';
import 'package:rateby/features/notifications/application/reminder_sync.dart';
import 'package:rateby/features/upgrade/application/billing_providers.dart';
import 'package:rateby/features/upgrade/application/entitlement_refresh.dart';

/// What happened during a sync pass (used to tell the user).
class AppSyncResult {
  const AppSyncResult({this.creditedPaydays = 0});

  /// Paydays whose goal contributions were just added.
  final int creditedPaydays;
}

/// Housekeeping that must run when the app opens and whenever it returns to
/// the foreground. Never throws: a failed step must not block the app.
class AppSync {
  AppSync(this._ref);

  final Ref _ref;

  Future<AppSyncResult> run() async {
    // Starts the store listener (purchases that finished while the app was
    // closed arrive through it) and re-checks the subscription, before the
    // reminders are planned, since daily-limit alerts depend on Plus.
    _ref.read(purchaseGatewayProvider);
    await _ref.read(entitlementRefreshProvider).run();

    var credited = 0;
    try {
      credited = await _ref
          .read(goalsControllerProvider.notifier)
          .creditDuePaydays();
    } on Object {
      // Try again on the next resume.
    }
    // A new day has started: refresh the queued reminders.
    await _ref.read(reminderSyncProvider).sync();
    return AppSyncResult(creditedPaydays: credited);
  }
}

final appSyncProvider = Provider<AppSync>(AppSync.new);
