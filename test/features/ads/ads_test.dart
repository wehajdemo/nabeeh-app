import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/features/ads/application/ads_providers.dart';
import 'package:rateby/features/ads/data/ad_config.dart';
import 'package:rateby/features/ads/presentation/ad_banner_slot.dart';

import '../../support/test_overrides.dart';

class FakeChoices implements AdChoices {
  FakeChoices({this.needed = true, this.fails = false});

  final bool needed;
  final bool fails;
  int shown = 0;

  @override
  Future<bool> isRequired() async {
    if (fails) throw Exception('no consent info');
    return needed;
  }

  @override
  Future<void> show() async => shown++;
}

Future<void> pumpSlot(
  WidgetTester tester, {
  required bool available,
  required bool plus,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        adsAvailableProvider.overrideWithValue(available),
        adBannerBuilderProvider.overrideWithValue(
          (_) => const Text('AD', textDirection: TextDirection.ltr),
        ),
        if (plus) plusActive(),
      ],
      child: const Directionality(
        textDirection: TextDirection.rtl,
        child: AdBannerSlot(),
      ),
    ),
  );
}

void main() {
  testWidgets('a free user on a build with ads sees the banner', (tester) async {
    await pumpSlot(tester, available: true, plus: false);
    expect(find.text('AD'), findsOneWidget);
  });

  testWidgets('نبيه بلس removes the ads', (tester) async {
    await pumpSlot(tester, available: true, plus: true);
    expect(find.text('AD'), findsNothing);
  });

  testWidgets('builds without ads (web, tests) never show one', (tester) async {
    await pumpSlot(tester, available: false, plus: false);
    expect(find.text('AD'), findsNothing);
  });

  test('ads disappear the moment a subscription becomes active', () {
    final free = ProviderContainer(
      overrides: [adsAvailableProvider.overrideWithValue(true)],
    );
    addTearDown(free.dispose);
    expect(free.read(showAdsProvider), isTrue);

    final plus = ProviderContainer(
      overrides: [adsAvailableProvider.overrideWithValue(true), plusActive()],
    );
    addTearDown(plus.dispose);
    expect(plus.read(showAdsProvider), isFalse);
  });

  group('ad choices entry in Settings', () {
    Future<bool> choicesRequired(FakeChoices? choices, {bool plus = false}) async {
      final container = ProviderContainer(
        overrides: [
          adsAvailableProvider.overrideWithValue(true),
          adChoicesProvider.overrideWithValue(choices),
          if (plus) plusActive(),
        ],
      );
      addTearDown(container.dispose);
      return container.read(adChoicesRequiredProvider.future);
    }

    test('shown when the consent framework says it is required', () async {
      expect(await choicesRequired(FakeChoices()), isTrue);
    });

    test('hidden when not required, failing, absent, or for subscribers',
        () async {
      expect(await choicesRequired(FakeChoices(needed: false)), isFalse);
      expect(await choicesRequired(FakeChoices(fails: true)), isFalse);
      expect(await choicesRequired(null), isFalse);
      expect(await choicesRequired(FakeChoices(), plus: true), isFalse);
    });
  });

  test('without --dart-define the build uses Google test ad ids', () {
    expect(AdConfig.usesTestIds, isTrue);
    expect(AdConfig.bannerId, startsWith('ca-app-pub-3940256099942544/'));
  });
}
