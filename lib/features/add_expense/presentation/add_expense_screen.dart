import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/features/ads/application/ads_providers.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_shadows.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/add_expense/application/add_expense_controller.dart';
import 'package:rateby/features/add_expense/application/add_expense_view_state.dart';
import 'package:rateby/features/add_expense/presentation/widgets/amount_display.dart';
import 'package:rateby/features/add_expense/presentation/widgets/numeric_keypad.dart';
import 'package:rateby/features/add_expense/presentation/widgets/quick_amount_chips.dart';
import 'package:rateby/features/add_expense/presentation/widgets/remaining_limit_strip.dart';
import 'package:rateby/features/add_expense/presentation/widgets/saved_banner.dart';

/// Fast expense entry: pick a preset or tap an amount, then save.
class AddExpenseScreen extends ConsumerWidget {
  const AddExpenseScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const AddExpenseScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(addExpenseViewStateProvider);
    final controller = ref.read(addExpenseControllerProvider.notifier);

    ref.listen<bool>(
      addExpenseViewStateProvider.select((v) => v.saveFailed),
      (previous, failed) {
        if (failed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.saveFailed)),
          );
        }
      },
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) unawaited(ref.read(adCoordinatorProvider).showDueExpenseAd());
      },
      child: Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: BackButton(color: AppColors.onSurface),
        title: Text(
          AppStrings.addExpenseTitle,
          style: AppTypography.headlineSm.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: AppSpacing.margin),
            child: BrandAvatar(size: 32),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.margin,
            AppSpacing.sm,
            AppSpacing.margin,
            AppSpacing.lg,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.md,
                children: [
                  RemainingLimitStrip(
                    remaining: view.remaining,
                    fraction: view.remainingFraction,
                  ),
                  _EntryCard(view: view, controller: controller),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: view.savedAmount == null
                        ? const SizedBox.shrink()
                        : SavedBanner(amount: view.savedAmount!),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

/// The white "sheet" card holding the readout, presets, keypad and button.
class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.view, required this.controller});

  final AddExpenseViewState view;
  final AddExpenseController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      shadows: AppShadows.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SheetHandle(),
          AppSpacing.gapMd,
          const _EntryHeader(),
          AppSpacing.gapSm,
          Text(
            AppStrings.addExpenseSubtitle,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          AppSpacing.gapMd,
          AmountDisplay(view: view),
          AppSpacing.gapMd,
          _NoteField(controller: controller),
          AppSpacing.gapMd,
          QuickAmountChips(
            amounts: AddExpenseViewState.quickAmounts,
            onSelected: controller.selectPreset,
          ),
          AppSpacing.gapMd,
          NumericKeypad(
            onDigit: controller.pressDigit,
            onDecimalPoint: controller.pressDecimalPoint,
            onBackspace: controller.backspace,
          ),
          AppSpacing.gapLg,
          PrimaryButton(
            label: view.isSaving
                ? AppStrings.savingExpense
                : AppStrings.saveExpense,
            icon: Icons.check_circle_outline,
            isLoading: view.isSaving,
            borderRadius: AppRadius.pill,
            onPressed: controller.save,
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
          borderRadius: AppRadius.pill,
        ),
        child: const SizedBox(width: 48, height: 6),
      ),
    );
  }
}

class _EntryHeader extends StatelessWidget {
  const _EntryHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.bolt, size: 24, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            AppStrings.addExpenseSheetTitle,
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        InfoPill(
          label: AppStrings.instantBadge,
          leading: Dot(color: AppColors.secondary, size: 8),
          background: AppColors.secondaryContainer30,
          foreground: AppColors.onSecondaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
      ],
    );
  }
}

/// Optional "what was it for?" text, cleared after each successful save.
class _NoteField extends ConsumerStatefulWidget {
  const _NoteField({required this.controller});

  final AddExpenseController controller;

  @override
  ConsumerState<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends ConsumerState<_NoteField> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(
      addExpenseControllerProvider.select((s) => s.note),
      (previous, note) {
        if (note.isEmpty && _text.text.isNotEmpty) _text.clear();
      },
    );
    return TextField(
      controller: _text,
      onChanged: widget.controller.setNote,
      maxLength: 60,
      textInputAction: TextInputAction.done,
      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        labelText: AppStrings.expenseNoteLabel,
        hintText: AppStrings.expenseNoteHint,
        counterText: '',
        prefixIcon: Icon(Icons.edit_note, color: AppColors.onSurfaceVariant),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
