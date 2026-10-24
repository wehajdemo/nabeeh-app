import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';

/// Label above a 52px filled field that gets a 2px emerald ring on focus
/// (DESIGN.md → "Input Fields").
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    super.key,
    this.controller,
    this.hint,
    this.suffixText,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.textInputAction,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;

  /// Fixed suffix such as `ر.س` that survives clearing the text.
  final String? suffixText;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextInputAction? textInputAction;

  static OutlineInputBorder _border(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: AppRadius.card,
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,
          style: AppTypography.headlineSm.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.headlineSm.copyWith(
              color: AppColors.outline,
              fontWeight: FontWeight.w400,
            ),
            suffixText: suffixText,
            suffixStyle: AppTypography.labelLg.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
            errorText: errorText,
            errorStyle: AppTypography.bodySm.copyWith(color: AppColors.error),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            border: _border(Colors.transparent, 0),
            enabledBorder: _border(Colors.transparent, 0),
            focusedBorder: _border(AppColors.primary, 2),
            errorBorder: _border(AppColors.error, 1),
            focusedErrorBorder: _border(AppColors.error, 2),
          ),
        ),
      ],
    );
  }
}
