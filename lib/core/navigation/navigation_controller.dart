import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Top-level destinations of the bottom navigation bar, in display order.
enum AppTab { home, goals, payments, upgrade, settings }

/// Holds the selected tab. Any feature can jump to another tab
/// (`ref.read(navigationControllerProvider.notifier).select(AppTab.upgrade)`)
/// without knowing about the shell widget.
class NavigationController extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.home;

  void select(AppTab tab) => state = tab;
}

final navigationControllerProvider =
    NotifierProvider<NavigationController, AppTab>(NavigationController.new);
