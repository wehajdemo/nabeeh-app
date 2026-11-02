import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/account/application/account_providers.dart';
import 'package:rateby/features/account/presentation/account_strings.dart';
import 'package:rateby/features/account/presentation/sign_in_prompt.dart';
import 'package:rateby/features/settings/presentation/widgets/settings_section.dart';

/// Settings block: sign in (optional), account copy status, sign out.
class CloudAccountSection extends ConsumerWidget {
  const CloudAccountSection({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AccountStrings.deleteCloud),
        content: const Text(AccountStrings.deleteCloudConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AccountStrings.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AccountStrings.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final done = await ref.read(backupSyncProvider.notifier).deleteCloudCopy();
    if (context.mounted) {
      AppToast.show(
        context,
        done ? AccountStrings.cloudDeleted : AccountStrings.cloudDeleteFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(accountUserProvider).valueOrNull;
    final backup = ref.watch(backupSyncProvider);

    if (user == null) {
      return SettingsSection(
        icon: Icons.cloud_outlined,
        title: AccountStrings.section,
        children: [
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.login,
                title: AccountStrings.signInTile,
                subtitle: AccountStrings.signInTileSubtitle,
                trailing:
                    Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                onTap: () =>
                    ensureSignedIn(context, ref, reason: SignInReason.optional),
              ),
            ],
          ),
        ],
      );
    }

    final status = switch (backup.status) {
      BackupStatus.syncing => AccountStrings.backupSyncing,
      BackupStatus.failed => AccountStrings.backupFailed,
      BackupStatus.idle => AccountStrings.backupOk,
    };
    return SettingsSection(
      icon: Icons.cloud_done_outlined,
      title: AccountStrings.section,
      children: [
        SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.account_circle_outlined,
              title: AccountStrings.signedInAs(user.email ?? user.name ?? ''),
              subtitle: status,
            ),
            SettingsTile(
              icon: Icons.cloud_off_outlined,
              iconColor: AppColors.onSurfaceVariant,
              title: AccountStrings.deleteCloud,
              subtitle: AccountStrings.deleteCloudSubtitle,
              onTap: () => _delete(context, ref),
            ),
            SettingsTile(
              icon: Icons.logout,
              iconColor: AppColors.onSurfaceVariant,
              title: AccountStrings.signOut,
              subtitle: AccountStrings.signOutSubtitle,
              onTap: () => ref.read(accountServiceProvider).signOut(),
            ),
          ],
        ),
      ],
    );
  }
}
