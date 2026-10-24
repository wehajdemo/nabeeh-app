import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/features/ads/application/ad_coordinator.dart';
import 'package:rateby/features/ads/data/ad_pacing.dart';

class FakeAds implements AdService {
  int interstitials = 0;
  int appOpens = 0;
  bool available = true;
  bool rewardedEarned = true;

  @override
  Future<bool> showInterstitial() async {
    if (available) interstitials++;
    return available;
  }

  @override
  Future<bool> showAppOpen() async {
    if (available) appOpens++;
    return available;
  }

  @override
  Future<bool> showRewarded() async => rewardedEarned;
}

void main() {
  late DateTime now;
  late FakeAds ads;
  late AdCoordinator coordinator;
  var enabled = true;

  setUp(() {
    now = DateTime(2026, 10, 23, 10);
    enabled = true;
    ads = FakeAds();
    coordinator = AdCoordinator(
      adsEnabled: () => enabled,
      service: ads,
      pacing: AdPacing(clock: () => now),
    );
  });

  Future<void> saveExpenses(int n) async {
    for (var i = 0; i < n; i++) {
      coordinator.noteExpenseSaved();
    }
    await coordinator.showDueExpenseAd();
  }

  test('an interstitial follows every third expense, not before', () async {
    await saveExpenses(2);
    expect(ads.interstitials, 0);
    await saveExpenses(1);
    expect(ads.interstitials, 1);
  });

  test('never shows the expense ad before the screen is left', () {
    for (var i = 0; i < 3; i++) {
      coordinator.noteExpenseSaved();
    }
    expect(ads.interstitials, 0);
  });

  test('minimum gap between interstitials is enforced', () async {
    await saveExpenses(3);
    now = now.add(const Duration(minutes: 1));
    await saveExpenses(3);
    expect(ads.interstitials, 1);
    now = now.add(const Duration(minutes: 4));
    await coordinator.showGoalsTabAd();
    expect(ads.interstitials, 2);
  });

  test('daily cap stops interstitials at three', () async {
    for (var i = 0; i < 6; i++) {
      await coordinator.showGoalsTabAd();
      now = now.add(const Duration(minutes: 5));
    }
    expect(ads.interstitials, 3);
    now = now.add(const Duration(days: 1));
    await coordinator.showGoalsTabAd();
    expect(ads.interstitials, 4);
  });

  test('Plus / no-ads builds never see an ad', () async {
    enabled = false;
    await saveExpenses(9);
    await coordinator.showGoalsTabAd();
    await coordinator.showAppOpenIfDue(const Duration(days: 2));
    expect(await coordinator.showRewarded(), isFalse);
    expect(ads.interstitials + ads.appOpens, 0);
  });

  test('a failed load does not use up the pacing budget', () async {
    ads.available = false;
    await coordinator.showGoalsTabAd();
    ads.available = true;
    await coordinator.showGoalsTabAd();
    expect(ads.interstitials, 1);
  });

  test('app-open needs a long absence and runs once a day', () async {
    await coordinator.showAppOpenIfDue(const Duration(hours: 1));
    expect(ads.appOpens, 0);
    await coordinator.showAppOpenIfDue(const Duration(hours: 5));
    await coordinator.showAppOpenIfDue(const Duration(hours: 5));
    expect(ads.appOpens, 1);
  });

  test('rewarded reports whether the video was earned', () async {
    expect(await coordinator.showRewarded(), isTrue);
    ads.rewardedEarned = false;
    expect(await coordinator.showRewarded(), isFalse);
  });
}
