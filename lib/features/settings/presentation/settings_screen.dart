import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/navigation/navigation_controller.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/ads/application/ads_providers.dart';
import 'package:rateby/features/budget/presentation/widgets/payday_sheet.dart';
import 'package:rateby/features/export/presentation/export_flow.dart';
import 'package:rateby/features/legal/domain/legal_content.dart';
import 'package:rateby/features/legal/presentation/legal_actions.dart';
import 'package:rateby/features/budget/presentation/widgets/salary_sheet.dart';
import 'package:rateby/features/settings/application/settings_controller.dart';
import 'package:rateby/features/settings/application/settings_state.dart';
import 'package:rateby/features/settings/presentation/settings_strings.dart';
import 'package:rateby/features/settings/presentation/widgets/account_section.dart';
import 'package:rateby/features/settings/presentation/widgets/appearance_sheet.dart';
import 'package:rateby/features/settings/presentation/widgets/commitments_sheet.dart';
import 'package:rateby/features/settings/presentation/widgets/financial_data_section.dart';
import 'package:rateby/features/settings/presentation/widgets/preferences_section.dart';
import 'package:rateby/features/settings/presentation/widgets/reset_section.dart';
import 'package:rateby/features/settings/presentation/widgets/settings_header.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';
import 'package:rateby/features/upgrade/domain/plus_gate.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';
import 'package:rateby/features/upgrade/presentation/plus_prompt.dart';

/// Settings tab. Opens editors, forwards changes to the controller and shows
/// the "saved" toast; holds no business logic.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Runs [action], then confirms with a toast — or reports the failure.
  Future<void> _save(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
      if (context.mounted) AppToast.show(context, SettingsStrings.saved);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(SettingsStrings.actionFailed)),
        );
      }
    }
  }

  /// Like [_save] for alert switches: also explains when the device blocks
  /// notifications.
  Future<void> _toggleAlert(
    BuildContext context,
    WidgetRef ref,
    Future<bool> Function() action,
  ) async {
    try {
      final permitted = await action();
      if (!context.mounted) return;
      if (permitted) {
        AppToast.show(context, SettingsStrings.saved);
      } else {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(content: Text(SettingsStrings.notificationsBlocked)),
          );
      }
    } on PlusRequiredException {
      if (context.mounted) {
        promptUpgrade(context, ref, SettingsStrings.dailyAlertsNeedPlus);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(SettingsStrings.actionFailed)),
        );
      }
    }
  }

  Future<void> _editSalary(
    BuildContext context,
    WidgetRef ref,
    SettingsState state,
  ) async {
    final salary = await showSalarySheet(
      context,
      initial: state.profile.netSalary,
    );
    if (salary == null || !context.mounted) return;
    await _save(
      context,
      () => ref.read(settingsControllerProvider.notifier).updateSalary(salary),
    );
  }

  Future<void> _editPayday(
    BuildContext context,
    WidgetRef ref,
    SettingsState state,
  ) async {
    final day = await showPaydaySheet(context, initial: state.profile.payDay);
    if (day == null || !context.mounted) return;
    await _save(
      context,
      () => ref.read(settingsControllerProvider.notifier).updatePayDay(day),
    );
  }

  Future<void> _editAppearance(
    BuildContext context,
    WidgetRef ref,
    SettingsState state,
  ) async {
    final mode = await showAppearanceSheet(
      context,
      current: state.preferences.appearance,
    );
    if (mode == null || mode == state.preferences.appearance) return;
    if (!context.mounted) return;
    // The whole app rebuilds with the new look, so no toast is needed.
    await ref.read(settingsControllerProvider.notifier).setAppearance(mode);
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        title: const Text(SettingsStrings.resetConfirmTitle),
        content: const Text(SettingsStrings.resetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(SettingsStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(SettingsStrings.resetConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(settingsControllerProvider.notifier).resetAll();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final isPlus = ref.watch(isPlusProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return settings.when(
      skipLoadingOnReload: true,
      loading: () => const LoadingView(),
      error: (error, stackTrace) => ErrorRetryView(
        onRetry: () => ref.invalidate(settingsControllerProvider),
      ),
      data: (state) => ScreenBody(
        children: [
          const SettingsHeader(),
          FinancialDataSection(
            state: state,
            onEditSalary: () => _editSalary(context, ref, state),
            onEditCommitments: () => showCommitmentsSheet(context),
            onEditPayday: () => _editPayday(context, ref, state),
          ),
          PreferencesSection(
            preferences: state.preferences,
            isPlus: isPlus,
            onAppearanceTap: () => _editAppearance(context, ref, state),
            onAdChoices: ref.watch(adChoicesRequiredProvider).valueOrNull == true
                ? () => ref.read(adChoicesProvider)?.show()
                : null,
            onDailyAlertsChanged: (v) =>
                _toggleAlert(context, ref, () => controller.setDailyLimitAlerts(v)),
            onPayoutAlertsChanged: (v) => _toggleAlert(
              context,
              ref,
              () => controller.setOfficialPayoutAlerts(v),
            ),
          ),
          AccountSection(
            plusMonthlyPrice: MoneyFormatter.format(PlusPlan.monthlyPrice),
            isPlus: isPlus,
            onUpgrade: () => ref
                .read(navigationControllerProvider.notifier)
                .select(AppTab.upgrade),
            onExport: () => runExportFlow(context, ref),
            onPrivacy: () => openLegal(context, LegalKind.privacy),
            onTerms: () => openLegal(context, LegalKind.terms),
            onSupport: () => openLegal(context, LegalKind.support),
          ),
          ResetSection(onReset: () => _confirmReset(context, ref)),
        ],
      ),
    );
  }
}
