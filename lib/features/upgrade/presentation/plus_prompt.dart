import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/navigation/navigation_controller.dart';
import 'package:rateby/core/widgets/widgets.dart';

/// Tells the user a feature needs "نبيه بلس" and opens the Upgrade tab.
void promptUpgrade(BuildContext context, WidgetRef ref, String message) {
  AppToast.show(context, message);
  ref.read(navigationControllerProvider.notifier).select(AppTab.upgrade);
}
