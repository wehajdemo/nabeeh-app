import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';

/// White button with an emerald outline and text.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.borderRadius = AppRadius.card,
  });

  final String label;
  final VoidCallback? onPressed;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.surfaceContainerLowest,
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        side: BorderSide(color: AppColors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        textStyle: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}
