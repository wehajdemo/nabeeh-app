import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_shadows.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';

/// Full-width emerald call-to-action (≥ 48px touch target per DESIGN.md).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.borderRadius = AppRadius.card,
  });

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Places the icon after the label (e.g. a trailing "next" arrow).
  final bool iconAtEnd;
  final bool isLoading;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: enabled ? AppShadows.primaryButton : null,
      ),
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          // While loading keep the brand colour; otherwise look disabled.
          disabledBackgroundColor:
              isLoading ? AppColors.primary : AppColors.surfaceContainerHigh,
          disabledForegroundColor:
              isLoading ? AppColors.onPrimary80 : AppColors.outline,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          textStyle: AppTypography.labelLg.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.onPrimary,
                ),
              )
            else if (icon != null && !iconAtEnd)
              Icon(icon, size: 24),
            if (isLoading || (icon != null && !iconAtEnd))
              const SizedBox(width: AppSpacing.sm),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            if (!isLoading && icon != null && iconAtEnd) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(icon, size: 24),
            ],
          ],
        ),
      ),
    );
  }
}
