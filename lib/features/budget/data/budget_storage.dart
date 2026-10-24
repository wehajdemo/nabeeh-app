/// Where the store keeps its serialized state between app launches.
///
/// Reads are synchronous so the store can restore itself in its constructor
/// (e.g. `SharedPreferences` is fully loaded before `runApp`).
abstract interface class BudgetStorage {
  String? read();
  Future<void> write(String json);
}

/// Keeps the JSON in memory. Used by tests and previews.
class MemoryBudgetStorage implements BudgetStorage {
  MemoryBudgetStorage([this._json]);

  String? _json;

  @override
  String? read() => _json;

  @override
  Future<void> write(String json) async => _json = json;
}
