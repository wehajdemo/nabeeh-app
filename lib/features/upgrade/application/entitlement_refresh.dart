import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/providers/clock_provider.dart';
import 'package:rateby/features/upgrade/application/billing_providers.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';

/// Re-checks the subscription with the server so renewals, cancellations
/// and refunds reach the app.
class EntitlementRefresh {
  EntitlementRefresh(this._ref);

  /// Do not ask the server more often than this (the app resumes often).
  static const Duration minInterval = Duration(minutes: 15);

  final Ref _ref;
  DateTime? _lastRun;

  /// Never throws. When the server cannot be reached the cached entitlement
  /// stays; it still expires on its own end date.
  Future<void> run() async {
    final verifier = _ref.read(subscriptionVerifierProvider);
    if (verifier == null) return;

    // Only people who ever subscribed need checking. Everyone else is
    // spared a network call (and an anonymous sign-in) at every launch;
    // a reinstall restores through "restore purchases".
    final current = _ref.read(entitlementProvider);
    if (current.plan == null) return;

    final now = _ref.read(clockProvider)();
    final last = _lastRun;
    final expired = !current.isActiveAt(now);
    if (!expired && last != null && now.difference(last) < minInterval) return;
    _lastRun = now;

    try {
      final fresh = await verifier.refresh();
      await _ref.read(entitlementProvider.notifier).update(fresh);
    } on Object {
      // Keep the cached copy.
    }
  }
}

final entitlementRefreshProvider = Provider<EntitlementRefresh>(
  EntitlementRefresh.new,
);
