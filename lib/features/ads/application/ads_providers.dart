import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/features/ads/application/ad_coordinator.dart';
import 'package:rateby/features/ads/data/ad_pacing.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';

/// Whether this build can show ads at all (Android with the ad SDK).
/// `main()` turns it on; tests and the web preview leave it off.
final adsAvailableProvider = Provider<bool>((ref) => false);

/// Ads are for free users only: "نبيه بلس" removes them.
final showAdsProvider = Provider<bool>(
  (ref) => ref.watch(adsAvailableProvider) && !ref.watch(isPlusProvider),
);

/// Full-screen ads (interstitial, rewarded, app-open). Overridden in `main()`.
final adServiceProvider = Provider<AdService>((ref) => const NoAdService());

final adPacingProvider = Provider<AdPacing>((ref) => AdPacing());

final adCoordinatorProvider = Provider<AdCoordinator>(
  (ref) => AdCoordinator(
    adsEnabled: () => ref.read(showAdsProvider),
    service: ref.watch(adServiceProvider),
    pacing: ref.watch(adPacingProvider),
  ),
);

/// Builds a native ad card. Overridden in `main()` with the AdMob one.
final adNativeBuilderProvider = Provider<WidgetBuilder>(
  (ref) => (context) => const SizedBox.shrink(),
);

/// Builds the banner widget. Overridden in `main()` with the AdMob one.
final adBannerBuilderProvider = Provider<WidgetBuilder>(
  (ref) => (context) => const SizedBox.shrink(),
);

/// The store-mandated "ad choices" form (EEA / UK users can change their
/// consent later). `null` where ads do not exist.
abstract interface class AdChoices {
  Future<bool> isRequired();
  Future<void> show();
}

final adChoicesProvider = Provider<AdChoices?>((ref) => null);

/// `true` when Settings should offer the ad-choices entry.
final adChoicesRequiredProvider = FutureProvider<bool>((ref) async {
  final choices = ref.watch(adChoicesProvider);
  if (choices == null || !ref.watch(showAdsProvider)) return false;
  try {
    return await choices.isRequired();
  } on Object {
    return false;
  }
});
