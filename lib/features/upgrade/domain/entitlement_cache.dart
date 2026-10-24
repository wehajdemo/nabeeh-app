import 'package:rateby/features/upgrade/domain/plus_entitlement.dart';

/// Keeps the last confirmed entitlement so the app works offline.
abstract interface class EntitlementCache {
  PlusEntitlement? read();
  Future<void> write(PlusEntitlement value);
  Future<void> clear();
}

class MemoryEntitlementCache implements EntitlementCache {
  MemoryEntitlementCache([this._value]);

  PlusEntitlement? _value;

  @override
  PlusEntitlement? read() => _value;

  @override
  Future<void> write(PlusEntitlement value) async => _value = value;

  @override
  Future<void> clear() async => _value = null;
}
