import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/amount_text_input_formatter.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';
import 'package:rateby/features/goals/presentation/goals_strings.dart';

/// Opens the add / edit goal sheet. Pass [editing] to prefill it.
/// Resolves to `null` when dismissed.
Future<GoalDraft?> showGoalFormSheet(
  BuildContext context, {
  SavingsGoal? editing,
}) {
  return showAppBottomSheet<GoalDraft>(
    context: context,
    builder: (_) => _GoalForm(editing: editing),
  );
}

class _GoalForm extends StatefulWidget {
  const _GoalForm({this.editing});

  final SavingsGoal? editing;

  @override
  State<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<_GoalForm> {
  late final TextEditingController _name;
  late final TextEditingController _target;
  late final TextEditingController _monthly;
  bool _submitted = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final goal = widget.editing;
    _name = TextEditingController(text: goal?.title ?? '');
    _target = TextEditingController(text: _plain(goal?.target));
    _monthly = TextEditingController(text: _plain(goal?.monthlyContribution));
  }

  static String _plain(Money? value) => value == null || value.isZero
      ? ''
      : MoneyFormatter.format(value).replaceAll(',', '');

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _monthly.dispose();
    super.dispose();
  }

  Money get _targetValue => Money.parse(_target.text);
  Money get _monthlyValue => Money.parse(_monthly.text);

  String? get _nameError => _submitted && _name.text.trim().isEmpty
      ? GoalsStrings.nameRequired
      : null;

  String? get _targetError =>
      _submitted && !_targetValue.isPositive ? GoalsStrings.targetRequired : null;

  String? get _monthlyError => _submitted && _monthlyValue > _targetValue
      ? GoalsStrings.monthlyTooHigh
      : null;

  void _submit() {
    setState(() => _submitted = true);
    if (_nameError != null || _targetError != null || _monthlyError != null) {
      return;
    }
    Navigator.of(context).pop(
      GoalDraft(
        title: _name.text.trim(),
        target: _targetValue,
        monthlyContribution: _monthlyValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        SheetHeader(
          title: _isEditing ? GoalsStrings.editTitle : GoalsStrings.addTitle,
          subtitle: GoalsStrings.addSubtitle,
          icon: _isEditing ? Icons.edit_outlined : Icons.add_task,
        ),
        AppTextField(
          label: GoalsStrings.goalName,
          hint: GoalsStrings.goalNameHint,
          controller: _name,
          errorText: _nameError,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        AppTextField(
          label: GoalsStrings.targetAmount,
          hint: '0',
          suffixText: AppStrings.currencySymbol,
          controller: _target,
          errorText: _targetError,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [AmountTextInputFormatter()],
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        AppTextField(
          label: GoalsStrings.monthlyAmount,
          hint: '0',
          suffixText: AppStrings.currencySymbol,
          controller: _monthly,
          errorText: _monthlyError,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [AmountTextInputFormatter()],
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
        ),
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: AppColors.outline),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                GoalsStrings.formInfo,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        PrimaryButton(
          label: GoalsStrings.saveGoal,
          icon: Icons.check,
          onPressed: _submit,
        ),
        SecondaryButton(
          label: GoalsStrings.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
