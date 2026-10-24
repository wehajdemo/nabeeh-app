import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/features/ads/application/ads_providers.dart';

/// Banner area above the bottom navigation. Takes no space for subscribers
/// (and in builds without ads).
class AdBannerSlot extends ConsumerWidget {
  const AdBannerSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(showAdsProvider)) return const SizedBox.shrink();
    return ref.watch(adBannerBuilderProvider)(context);
  }
}
