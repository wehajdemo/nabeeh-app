import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/presentation/budget_strings.dart';
import 'package:rateby/features/budget/presentation/widgets/payday_picker.dart';

/// Edit-payday sheet. Resolves to the chosen day, or `null` if dismissed.
Future<int?> showPaydaySheet(BuildContext context, {required int initial}) {
  return showAppBottomSheet<int>(
    context: context,
    builder: (_) => _PaydaySheet(initial: initial),
  );
}

class _PaydaySheet extends StatefulWidget {
  const _PaydaySheet({required this.initial});

  final int initial;

  @override
  State<_PaydaySheet> createState() => _PaydaySheetState();
}

class _PaydaySheetState extends State<_PaydaySheet> {
  late int _day = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        const SheetHeader(
          title: BudgetStrings.paydayTitle,
          subtitle: BudgetStrings.paydaySubtitle,
          icon: Icons.event_repeat_outlined,
        ),
        PaydayPicker(
          selectedDay: _day,
          onSelected: (d) => setState(() => _day = d),
        ),
        PrimaryButton(
          label: BudgetStrings.save,
          icon: Icons.check_circle_outline,
          onPressed: () => Navigator.of(context).pop(_day),
        ),
      ],
    );
  }
}
