import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';

/// Horizontal progress bar that fills from the reading-start edge
/// (right in RTL) and animates between values.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    required this.value,
    super.key,
    this.height = AppSizes.progressHeightSm,
    this.inset = 0,
    this.trackColor,
    this.fill,
    this.duration = const Duration(milliseconds: 700),
  });

  /// 0‥1.
  final double value;
  final double height;

  /// Padding between track and fill (the hero bar has a 2px inset).
  final double inset;
  /// Defaults to the container-high surface of the current theme.
  final Color? trackColor;
  final Gradient? fill;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0).toDouble();
    return Semantics(
      value: '${(target * 100).round()}%',
      child: Container(
        height: height,
        padding: EdgeInsets.all(inset),
        decoration: BoxDecoration(
          color: trackColor ?? AppColors.surfaceContainerHigh,
          borderRadius: AppRadius.pill,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.pill,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: target),
            duration: duration,
            curve: Curves.easeOut,
            builder: (context, factor, _) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: factor,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: fill ??
                        LinearGradient(
                          colors: [
                            AppColors.primaryContainer,
                            AppColors.primaryContainer,
                          ],
                        ),
                    borderRadius: AppRadius.pill,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
