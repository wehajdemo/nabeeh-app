import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/navigation/navigation_controller.dart';
import 'package:rateby/features/ads/application/ads_providers.dart';
import 'package:rateby/features/ads/presentation/ad_banner_slot.dart';
import 'package:rateby/features/goals/presentation/goals_screen.dart';
import 'package:rateby/features/home/presentation/home_screen.dart';
import 'package:rateby/features/payments/presentation/payments_screen.dart';
import 'package:rateby/features/settings/presentation/settings_screen.dart';
import 'package:rateby/features/upgrade/presentation/upgrade_screen.dart';
import 'package:rateby/features/shell/presentation/widgets/app_bottom_nav.dart';
import 'package:rateby/features/shell/presentation/widgets/app_top_bar.dart';

/// App chrome: top bar + selected tab + bottom navigation.
///
/// Tabs are kept alive in an [IndexedStack] so scroll position and state
/// survive switching. Also the place where full-screen ads are triggered by
/// navigation: opening the Goals tab, and returning after a long absence.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed && _pausedAt != null) {
      final away = DateTime.now().difference(_pausedAt!);
      _pausedAt = null;
      unawaited(ref.read(adCoordinatorProvider).showAppOpenIfDue(away));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(navigationControllerProvider);

    ref.listen<AppTab>(navigationControllerProvider, (previous, next) {
      if (next == AppTab.goals && previous != AppTab.goals) {
        unawaited(ref.read(adCoordinatorProvider).showGoalsTabAd());
      }
    });

    return Scaffold(
      appBar: const AppTopBar(),
      body: IndexedStack(
        index: tab.index,
        children: const [
          HomeScreen(),
          GoalsScreen(),
          PaymentsScreen(),
          UpgradeScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerSlot(),
          AppBottomNav(
            selected: tab,
            onSelected: ref.read(navigationControllerProvider.notifier).select,
          ),
        ],
      ),
    );
  }
}
