import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';

/// Scrollable, width-constrained column used by every tab screen so they all
/// share the same margins, spacing and pull-to-refresh behaviour.
class ScreenBody extends StatelessWidget {
  const ScreenBody({
    required this.children,
    super.key,
    this.onRefresh,
    this.bottomPadding = AppSpacing.lg,
    this.spacing = AppSpacing.md,
  });

  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  /// Extra room under the content, e.g. to clear a floating button.
  final double bottomPadding;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final scroll = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.xs,
        AppSpacing.margin,
        bottomPadding,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.maxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing,
            children: children,
          ),
        ),
      ),
    );

    final refresh = onRefresh;
    if (refresh == null) return scroll;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: refresh,
      child: scroll,
    );
  }
}
