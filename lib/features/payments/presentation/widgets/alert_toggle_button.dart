import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/features/payments/presentation/payments_strings.dart';

/// "تنبيهي" pill that flips to "مفعل للدفعة القادمة" when on.
class AlertToggleButton extends StatelessWidget {
  const AlertToggleButton({
    required this.isOn,
    required this.onPressed,
    super.key,
  });

  final bool isOn;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isOn,
      child: Material(
        color: isOn ? AppColors.primaryContainer : AppColors.surfaceContainer,
        borderRadius: AppRadius.pill,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.pill,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutterSm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOn
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_none,
                    size: 18,
                    color: isOn ? AppColors.onPrimary : AppColors.onSurface,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOn ? PaymentsStrings.alertOn : PaymentsStrings.alert,
                    style: AppTypography.labelMd.copyWith(
                      color: isOn ? AppColors.onPrimary : AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
