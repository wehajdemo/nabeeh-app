import 'package:rateby/features/budget/data/budget_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the store as one JSON string in `SharedPreferences`
/// (on-device only; nothing is sent anywhere).
class SharedPrefsBudgetStorage implements BudgetStorage {
  const SharedPrefsBudgetStorage(this._prefs);

  static const String _key = 'rateby.budget.v1';

  final SharedPreferences _prefs;

  @override
  String? read() => _prefs.getString(_key);

  @override
  Future<void> write(String json) async {
    final ok = await _prefs.setString(_key, json);
    if (!ok) throw StateError('Could not persist budget data');
  }
}
