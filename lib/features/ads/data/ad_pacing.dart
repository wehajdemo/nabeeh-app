import 'package:rateby/features/ads/data/ad_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers when full-screen ads last ran so they never pile up: a minimum
/// gap and a daily cap for interstitials, once a day for app-open ads.
/// Persists in [SharedPreferences] when given one, otherwise lives in memory.
class AdPacing {
  AdPacing({SharedPreferences? prefs, DateTime Function()? clock})
      : _prefs = prefs,
        _clock = clock ?? DateTime.now;

  static const String _kLastInterstitial = 'ads.lastInterstitialMs';
  static const String _kDay = 'ads.day';
  static const String _kDayCount = 'ads.interstitialsToday';
  static const String _kAppOpenDay = 'ads.appOpenDay';

  final SharedPreferences? _prefs;
  final DateTime Function() _clock;
  final Map<String, Object> _memory = {};

  int? _int(String key) =>
      _prefs != null ? _prefs.getInt(key) : _memory[key] as int?;
  String? _string(String key) =>
      _prefs != null ? _prefs.getString(key) : _memory[key] as String?;

  Future<void> _setInt(String key, int value) async {
    _memory[key] = value;
    await _prefs?.setInt(key, value);
  }

  Future<void> _setString(String key, String value) async {
    _memory[key] = value;
    await _prefs?.setString(key, value);
  }

  String _today() {
    final n = _clock();
    return '${n.year}-${n.month}-${n.day}';
  }

  bool canShowInterstitial() {
    final last = _int(_kLastInterstitial);
    if (last != null) {
      final since = _clock().difference(DateTime.fromMillisecondsSinceEpoch(last));
      if (since < AdConfig.interstitialGap) return false;
    }
    final shownToday = _string(_kDay) == _today() ? (_int(_kDayCount) ?? 0) : 0;
    return shownToday < AdConfig.interstitialsPerDay;
  }

  Future<void> markInterstitialShown() async {
    final today = _today();
    final count = _string(_kDay) == today ? (_int(_kDayCount) ?? 0) : 0;
    await _setInt(_kLastInterstitial, _clock().millisecondsSinceEpoch);
    await _setString(_kDay, today);
    await _setInt(_kDayCount, count + 1);
  }

  bool canShowAppOpen() => _string(_kAppOpenDay) != _today();

  Future<void> markAppOpenShown() => _setString(_kAppOpenDay, _today());
}
