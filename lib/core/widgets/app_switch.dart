import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';

/// Emerald on/off switch.
class AppSwitch extends StatelessWidget {
  const AppSwitch({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.surfaceContainerHigh,
      ),
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.onPrimary
            : AppColors.surfaceContainerLowest,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }
}
