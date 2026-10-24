import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/presentation/budget_strings.dart';
import 'package:rateby/features/budget/presentation/widgets/commitment_form_sheet.dart';
import 'package:rateby/features/budget/presentation/widgets/commitment_tile.dart';
import 'package:rateby/features/settings/application/settings_controller.dart';
import 'package:rateby/features/settings/presentation/settings_strings.dart';

/// Manage fixed commitments: list, remove, add. Reads live state so the list
/// updates while the sheet stays open.
Future<void> showCommitmentsSheet(BuildContext context) {
  return showAppBottomSheet<void>(
    context: context,
    builder: (_) => const _CommitmentsSheet(),
  );
}

class _CommitmentsSheet extends ConsumerWidget {
  const _CommitmentsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commitments = ref.watch(
      settingsControllerProvider.select(
        (s) => s.valueOrNull?.profile.commitments ?? const [],
      ),
    );
    final controller = ref.read(settingsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.gutterSm,
      children: [
        const SheetHeader(
          title: SettingsStrings.commitmentsSheetTitle,
          subtitle: SettingsStrings.commitmentsSheetSubtitle,
          icon: Icons.receipt_long_outlined,
        ),
        if (commitments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: Text(
                SettingsStrings.commitmentsEmpty,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        for (final c in commitments)
          CommitmentTile(
            key: ValueKey(c.id),
            title: c.title,
            amount: c.amount,
            category: c.category,
            onRemove: () => controller.removeCommitment(c.id),
          ),
        DashedBorderButton(
          label: BudgetStrings.addCommitmentCta,
          onPressed: () async {
            final draft = await showCommitmentFormSheet(context);
            if (draft != null) await controller.addCommitment(draft);
          },
        ),
      ],
    );
  }
}
