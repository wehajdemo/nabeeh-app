import 'package:rateby/features/ads/data/ad_config.dart';
import 'package:rateby/features/ads/data/ad_pacing.dart';

/// Full-screen ad formats. Each call completes once the ad is closed and
/// answers whether one was actually shown (rewarded: whether it was earned).
/// Never throws; a missing ad is simply `false`.
abstract interface class AdService {
  Future<bool> showInterstitial();
  Future<bool> showAppOpen();
  Future<bool> showRewarded();
}

/// Used where ads do not exist (web, tests, Plus builds).
class NoAdService implements AdService {
  const NoAdService();

  @override
  Future<bool> showInterstitial() async => false;
  @override
  Future<bool> showAppOpen() async => false;
  @override
  Future<bool> showRewarded() async => false;
}

/// Decides *when* an ad may run; [AdService] decides how. Rules:
///  * an interstitial follows every [AdConfig.expensesPerInterstitial]th
///    saved expense, but only once the user has left the entry screen;
///  * interstitials also open the Goals tab;
///  * all interstitials obey the minimum gap and daily cap in [AdPacing];
///  * an app-open ad runs once a day after a long absence;
///  * nothing ever runs for Plus subscribers or on builds without ads.
class AdCoordinator {
  AdCoordinator({
    required bool Function() adsEnabled,
    required AdService service,
    required AdPacing pacing,
  })  : _enabled = adsEnabled,
        _service = service,
        _pacing = pacing;

  final bool Function() _enabled;
  final AdService _service;
  final AdPacing _pacing;

  int _savedExpenses = 0;
  bool _expenseAdDue = false;

  /// Call after an expense was stored. The ad itself waits for
  /// [showDueExpenseAd] so it never covers the "saved" confirmation.
  void noteExpenseSaved() {
    if (!_enabled()) return;
    _savedExpenses++;
    if (_savedExpenses % AdConfig.expensesPerInterstitial == 0) {
      _expenseAdDue = true;
    }
  }

  /// Call when the user leaves the expense screen.
  Future<void> showDueExpenseAd() async {
    if (!_expenseAdDue) return;
    _expenseAdDue = false;
    await _interstitial();
  }

  Future<void> showGoalsTabAd() => _interstitial();

  Future<void> _interstitial() async {
    if (!_enabled() || !_pacing.canShowInterstitial()) return;
    if (await _service.showInterstitial()) {
      await _pacing.markInterstitialShown();
    }
  }

  /// Call when the app returns to the foreground after [away].
  Future<void> showAppOpenIfDue(Duration away) async {
    if (!_enabled() || away < AdConfig.appOpenAway) return;
    if (!_pacing.canShowAppOpen()) return;
    if (await _service.showAppOpen()) await _pacing.markAppOpenShown();
  }

  /// `true` when the user watched the video to the end.
  Future<bool> showRewarded() async {
    if (!_enabled()) return false;
    return _service.showRewarded();
  }
}
