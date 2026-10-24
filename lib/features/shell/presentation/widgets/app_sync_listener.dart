import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/notifications/application/reminder_sync.dart';
import 'package:rateby/features/shell/application/app_sync.dart';
import 'package:rateby/features/shell/presentation/shell_strings.dart';

/// Runs [AppSync] on start and on resume, and reports what it did.
class AppSyncListener extends ConsumerWidget {
  const AppSyncListener({required this.child, super.key});

  final Widget child;

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(appSyncProvider).run();
    if (!context.mounted) return;
    if (result.creditedPaydays > 0) {
      AppToast.show(context, ShellStrings.goalsCredited(result.creditedPaydays));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(reminderAutoSyncProvider);
    return AppResumeListener(
      onResume: () => _sync(context, ref),
      child: child,
    );
  }
}
