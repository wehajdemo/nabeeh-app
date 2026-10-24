import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';

/// Horizontally scrolling single-select pill chips.
class ChoiceChipBar<T> extends StatelessWidget {
  const ChoiceChipBar({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  /// Value → label, in display order.
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          for (final entry in options.entries)
            _Pill(
              label: entry.value,
              isSelected: entry.key == selected,
              onTap: () => onSelected(entry.key),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected
            ? AppColors.primary
            : AppColors.surfaceContainerLowest,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: isSelected
                    ? AppColors.onPrimary
                    : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
