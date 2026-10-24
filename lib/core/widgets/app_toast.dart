import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';

/// Dark floating confirmation ("تم الحفظ بنجاح") shown at the bottom.
abstract final class AppToast {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.inverseSurface,
          duration: const Duration(milliseconds: 2500),
          margin: const EdgeInsets.all(AppSpacing.md),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle,
                size: 20,
                color: isError ? AppColors.errorContainer : AppColors.secondaryFixed,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.inverseOnSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
