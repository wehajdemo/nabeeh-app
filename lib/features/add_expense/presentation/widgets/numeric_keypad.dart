import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_shadows.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';

/// 3×4 numeric pad.
///
/// Laid out left-to-right (1 2 3 / 4 5 6 / 7 8 9 / . 0 ⌫) regardless of the
/// app's RTL direction, because that is the universal muscle-memory layout
/// for digits. Pass [textDirection] = `TextDirection.rtl` to mirror the
/// exported mock-up exactly (it shows 3 2 1 because the HTML inherited RTL).
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    required this.onDigit,
    required this.onDecimalPoint,
    required this.onBackspace,
    super.key,
    this.textDirection = TextDirection.ltr,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDecimalPoint;
  final VoidCallback onBackspace;
  final TextDirection textDirection;

  static const List<List<String>> _digitRows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: Column(
        spacing: AppSpacing.gutterSm,
        children: [
          for (final row in _digitRows)
            _KeyRow(
              children: [
                for (final digit in row)
                  _KeypadKey.label(digit, onTap: () => onDigit(digit)),
              ],
            ),
          _KeyRow(
            children: [
              _KeypadKey.label('.', onTap: onDecimalPoint),
              _KeypadKey.label('0', onTap: () => onDigit('0')),
              _KeypadKey.icon(
                Icons.backspace_outlined,
                semanticLabel: AppStrings.backspace,
                onTap: onBackspace,
                background: AppColors.surfaceContainerHigh,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeyRow extends StatelessWidget {
  const _KeyRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.gutterSm,
      children: [for (final child in children) Expanded(child: child)],
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey._({
    required this.onTap,
    required this.child,
    required this.background,
    this.semanticLabel,
  });

  factory _KeypadKey.label(String label, {required VoidCallback onTap}) {
    return _KeypadKey._(
      onTap: onTap,
      background: AppColors.surface,
      child: Text(
        label,
        style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface),
      ),
    );
  }

  factory _KeypadKey.icon(
    IconData icon, {
    required VoidCallback onTap,
    required String semanticLabel,
    required Color background,
  }) {
    return _KeypadKey._(
      onTap: onTap,
      background: background,
      semanticLabel: semanticLabel,
      child: Icon(icon, size: 24, color: AppColors.onSurface),
    );
  }

  final VoidCallback onTap;
  final Widget child;
  final Color background;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: AppRadius.card,
          boxShadow: AppShadows.card,
        ),
        child: Material(
          color: background,
          borderRadius: AppRadius.card,
          child: InkWell(
            borderRadius: AppRadius.card,
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: SizedBox(
              height: AppSizes.keypadKeyHeight,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
