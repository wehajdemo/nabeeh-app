import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/features/account/application/account_providers.dart';
import 'package:rateby/features/account/presentation/account_strings.dart';

/// Asks which copy to keep when this phone and the account hold different
/// data. Wraps the main shell.
class BackupConflictListener extends ConsumerWidget {
  const BackupConflictListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<BackupState>(backupSyncProvider, (previous, next) async {
      if (next.conflict == null || previous?.conflict != null) return;
      final useCloud = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text(AccountStrings.conflictTitle),
          content: const Text(AccountStrings.conflictBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AccountStrings.keepPhone),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(AccountStrings.useCloud),
            ),
          ],
        ),
      );
      final controller = ref.read(backupSyncProvider.notifier);
      if (useCloud ?? false) {
        await controller.useCloudCopy();
      } else {
        await controller.keepThisPhone();
      }
    });
    return child;
  }
}
