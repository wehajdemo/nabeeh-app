import 'dart:convert';

import 'package:rateby/features/upgrade/domain/entitlement_cache.dart';
import 'package:rateby/features/upgrade/domain/plus_entitlement.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsEntitlementCache implements EntitlementCache {
  const SharedPrefsEntitlementCache(this._prefs);

  static const String _key = 'rateby.entitlement.v1';

  final SharedPreferences _prefs;

  @override
  PlusEntitlement? read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return PlusEntitlement.fromJson(jsonDecode(raw));
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(PlusEntitlement value) async {
    await _prefs.setString(_key, jsonEncode(value.toJson()));
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
