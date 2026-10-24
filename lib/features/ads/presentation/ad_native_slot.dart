import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/features/ads/application/ads_providers.dart';

/// A native ad card inside a page. Takes no space for subscribers (and in
/// builds without ads).
class AdNativeSlot extends ConsumerWidget {
  const AdNativeSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(showAdsProvider)) return const SizedBox.shrink();
    return ref.watch(adNativeBuilderProvider)(context);
  }
}
