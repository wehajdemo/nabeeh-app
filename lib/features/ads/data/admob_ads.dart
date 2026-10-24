import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rateby/features/ads/application/ad_coordinator.dart';
import 'package:rateby/features/ads/application/ads_providers.dart';
import 'package:rateby/features/ads/data/ad_config.dart';

/// Starts the ad SDK once, after asking for consent where the law requires
/// it (Google's User Messaging Platform: EEA / UK).
abstract final class AdMobBootstrap {
  static Future<bool>? _ready;

  /// Completes with `true` when ads may be requested. Never throws.
  static Future<bool> ensureReady() => _ready ??= _start();

  static Future<bool> _start() async {
    try {
      await _requestConsent();
      if (!await ConsentInformation.instance.canRequestAds()) return false;
      await MobileAds.instance.initialize();
      return true;
    } on Object {
      return false;
    }
  }

  static Future<void> _requestConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        // Shows the consent form only when one is required.
        ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
          if (!done.isCompleted) done.complete();
        });
      },
      (FormError error) {
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {},
    );
  }
}

/// An anchored adaptive AdMob banner: sized to the screen width, which earns
/// more than the fixed 320×50. Shows nothing until an ad has loaded, so a
/// failed request leaves no empty strip.
class AdMobBanner extends StatefulWidget {
  const AdMobBanner({super.key});

  @override
  State<AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<AdMobBanner> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    unawaited(_load(MediaQuery.sizeOf(context).width.truncate()));
  }

  Future<void> _load(int width) async {
    if (!await AdMobBootstrap.ensureReady() || !mounted) return;
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted) return;
    final ad = BannerAd(
      adUnitId: AdConfig.bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}

/// A native ad drawn with Google's small template so it sits in the page
/// like a card. Labelled "إعلان" and hidden until it has loaded.
class AdMobNative extends StatefulWidget {
  const AdMobNative({super.key});

  @override
  State<AdMobNative> createState() => _AdMobNativeState();
}

class _AdMobNativeState extends State<AdMobNative> {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    if (!await AdMobBootstrap.ensureReady() || !mounted) return;
    final ad = NativeAd(
      adUnitId: AdConfig.nativeId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        cornerRadius: 16,
      ),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 4),
          child: Text(
            'إعلان',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 90, maxHeight: 120),
          child: AdWidget(ad: ad),
        ),
      ],
    );
  }
}

/// Interstitial, rewarded and app-open ads. Each is loaded on demand with a
/// short timeout: if no ad arrives in time the moment simply passes and the
/// user is never kept waiting.
class AdMobService implements AdService {
  const AdMobService();

  static const Duration _loadTimeout = Duration(seconds: 5);

  @override
  Future<bool> showInterstitial() async {
    if (!await AdMobBootstrap.ensureReady()) return false;
    final loaded = Completer<InterstitialAd?>();
    await InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: loaded.complete,
        onAdFailedToLoad: (_) => loaded.complete(null),
      ),
    );
    final ad = await _await(loaded.future);
    if (ad == null) return false;
    return _present<InterstitialAd>(
      (callback) => ad.fullScreenContentCallback = callback,
      ad.show,
      ad.dispose,
    );
  }

  @override
  Future<bool> showAppOpen() async {
    if (!await AdMobBootstrap.ensureReady()) return false;
    final loaded = Completer<AppOpenAd?>();
    await AppOpenAd.load(
      adUnitId: AdConfig.appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: loaded.complete,
        onAdFailedToLoad: (_) => loaded.complete(null),
      ),
    );
    final ad = await _await(loaded.future);
    if (ad == null) return false;
    return _present<AppOpenAd>(
      (callback) => ad.fullScreenContentCallback = callback,
      ad.show,
      ad.dispose,
    );
  }

  @override
  Future<bool> showRewarded() async {
    if (!await AdMobBootstrap.ensureReady()) return false;
    final loaded = Completer<RewardedAd?>();
    await RewardedAd.load(
      adUnitId: AdConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: loaded.complete,
        onAdFailedToLoad: (_) => loaded.complete(null),
      ),
    );
    final ad = await _await(loaded.future, timeout: const Duration(seconds: 8));
    if (ad == null) return false;
    var earned = false;
    await _present<RewardedAd>(
      (callback) => ad.fullScreenContentCallback = callback,
      () => ad.show(onUserEarnedReward: (_, __) => earned = true),
      ad.dispose,
    );
    return earned;
  }

  Future<T?> _await<T>(
    Future<T?> future, {
    Duration timeout = _loadTimeout,
  }) {
    return future.timeout(timeout, onTimeout: () => null).catchError(
          (Object _) => null,
        );
  }

  /// Runs [show] with a callback that completes when the ad closes.
  Future<bool> _present<T>(
    void Function(FullScreenContentCallback<T>) attach,
    Future<void> Function() show,
    VoidCallback dispose,
  ) async {
    final closed = Completer<bool>();
    final callback = FullScreenContentCallback<T>(
      onAdDismissedFullScreenContent: (_) {
        dispose();
        if (!closed.isCompleted) closed.complete(true);
      },
      onAdFailedToShowFullScreenContent: (_, __) {
        dispose();
        if (!closed.isCompleted) closed.complete(false);
      },
    );
    try {
      attach(callback);
      await show();
    } on Object {
      dispose();
      return false;
    }
    return closed.future;
  }
}

/// Google's consent form, reopened from Settings.
class AdMobChoices implements AdChoices {
  const AdMobChoices();

  @override
  Future<bool> isRequired() async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  @override
  Future<void> show() {
    final done = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((FormError? error) {
      if (!done.isCompleted) done.complete();
    });
    return done.future;
  }
}
