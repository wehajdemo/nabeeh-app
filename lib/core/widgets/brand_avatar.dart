import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/widgets/brand_mark.dart';

/// Round avatar carrying the Nabeeh mark (top bars, headers).
class BrandAvatar extends StatelessWidget {
  const BrandAvatar({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: size,
        child: BrandMark(size: size),
      ),
    );
  }
}
