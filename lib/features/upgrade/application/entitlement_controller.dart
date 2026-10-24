import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/providers/clock_provider.dart';
import 'package:rateby/features/upgrade/domain/entitlement_cache.dart';
import 'package:rateby/features/upgrade/domain/plus_entitlement.dart';

/// Where the entitlement is remembered between launches.
final entitlementCacheProvider = Provider<EntitlementCache>(
  (ref) => MemoryEntitlementCache(),
);

/// The user's current "نبيه بلس" entitlement, as last confirmed by the
/// server. Starts from the cached copy.
class EntitlementController extends Notifier<PlusEntitlement> {
  @override
  PlusEntitlement build() =>
      ref.watch(entitlementCacheProvider).read() ?? const PlusEntitlement.none();

  /// Stores a server-confirmed entitlement.
  Future<void> update(PlusEntitlement entitlement) async {
    state = entitlement;
    await ref.read(entitlementCacheProvider).write(entitlement);
  }

  Future<void> clear() async {
    state = const PlusEntitlement.none();
    await ref.read(entitlementCacheProvider).clear();
  }
}

final entitlementProvider =
    NotifierProvider<EntitlementController, PlusEntitlement>(
  EntitlementController.new,
);

/// `true` while the user has an active Plus subscription. Gate Plus-only
/// features on this.
final isPlusProvider = Provider<bool>((ref) {
  final now = ref.watch(clockProvider)();
  return ref.watch(entitlementProvider).isActiveAt(now);
});
