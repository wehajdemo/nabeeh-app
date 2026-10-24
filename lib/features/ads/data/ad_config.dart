import 'package:flutter/foundation.dart';

/// AdMob ad-unit ids. The defaults are Google's public **test** ids, which
/// are safe to use in development (real ids on test devices risk an account
/// ban). Build releases with one define per unit, from the platform's file:
///
///   flutter build appbundle --dart-define-from-file=config/release.defines.json
///   flutter build ipa       --dart-define-from-file=config/release.ios.defines.json
///
/// (keys: ADMOB_BANNER_ID, ADMOB_INTERSTITIAL_ID, ADMOB_REWARDED_ID,
/// ADMOB_NATIVE_ID, ADMOB_APP_OPEN_ID) and set the app id in
/// AndroidManifest.xml / Info.plist (see docs/RELEASE_CHECKLIST.md).
abstract final class AdConfig {
  static bool get _ios => defaultTargetPlatform == TargetPlatform.iOS;

  static String get testBannerId => _ios
      ? 'ca-app-pub-3940256099942544/2934735716'
      : 'ca-app-pub-3940256099942544/6300978111';
  static String get testInterstitialId => _ios
      ? 'ca-app-pub-3940256099942544/4411468910'
      : 'ca-app-pub-3940256099942544/1033173712';
  static String get testRewardedId => _ios
      ? 'ca-app-pub-3940256099942544/1712485313'
      : 'ca-app-pub-3940256099942544/5224354917';
  static String get testNativeId => _ios
      ? 'ca-app-pub-3940256099942544/3986624511'
      : 'ca-app-pub-3940256099942544/2247696110';
  static String get testAppOpenId => _ios
      ? 'ca-app-pub-3940256099942544/5575463023'
      : 'ca-app-pub-3940256099942544/9257395921';

  static const String _banner = String.fromEnvironment('ADMOB_BANNER_ID');
  static const String _interstitial =
      String.fromEnvironment('ADMOB_INTERSTITIAL_ID');
  static const String _rewarded = String.fromEnvironment('ADMOB_REWARDED_ID');
  static const String _native = String.fromEnvironment('ADMOB_NATIVE_ID');
  static const String _appOpen = String.fromEnvironment('ADMOB_APP_OPEN_ID');

  static String get bannerId => _banner.isEmpty ? testBannerId : _banner;
  static String get interstitialId =>
      _interstitial.isEmpty ? testInterstitialId : _interstitial;
  static String get rewardedId =>
      _rewarded.isEmpty ? testRewardedId : _rewarded;
  static String get nativeId => _native.isEmpty ? testNativeId : _native;
  static String get appOpenId => _appOpen.isEmpty ? testAppOpenId : _appOpen;

  static bool get usesTestIds => bannerId == testBannerId;

  // ── Pacing: how often a full-screen ad may appear ───────────────────────
  /// An interstitial is offered after every Nth logged expense.
  static const int expensesPerInterstitial = 3;

  /// Minimum time between two interstitials.
  static const Duration interstitialGap = Duration(minutes: 3);

  /// Interstitials per calendar day.
  static const int interstitialsPerDay = 3;

  /// An app-open ad needs the app to have been away at least this long…
  static const Duration appOpenAway = Duration(hours: 4);
  // …and is shown once per calendar day.
}
