import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';

/// Centered spinner for first-load states.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

/// Error message with a retry action.
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({
    required this.onRetry,
    super.key,
    this.message = AppStrings.loadError,
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.cardLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.md,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: AppColors.outline,
            ),
            Text(
              message,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                shape: const StadiumBorder(),
              ),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
