import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/navigation/navigation_controller.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';

/// Presentation data for one bottom-nav destination.
class _Destination {
  const _Destination(this.tab, this.label, this.icon, this.activeIcon);

  final AppTab tab;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const List<_Destination> _destinations = [
  _Destination(
    AppTab.home,
    AppStrings.navHome,
    Icons.account_balance_wallet_outlined,
    Icons.account_balance_wallet,
  ),
  _Destination(
    AppTab.goals,
    AppStrings.navGoals,
    Icons.savings_outlined,
    Icons.savings,
  ),
  _Destination(
    AppTab.payments,
    AppStrings.navPayments,
    Icons.event_note_outlined,
    Icons.event_note,
  ),
  _Destination(
    AppTab.upgrade,
    AppStrings.navUpgrade,
    Icons.workspace_premium_outlined,
    Icons.workspace_premium,
  ),
  _Destination(
    AppTab.settings,
    AppStrings.navSettings,
    Icons.settings_outlined,
    Icons.settings,
  ),
];

/// Five-destination bottom bar. Order follows the reading direction, so in
/// RTL "الرئيسية" is the right-most item.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final AppTab selected;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: Colors.black26,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final destination in _destinations)
                _NavItem(
                  destination: destination,
                  isSelected: destination.tab == selected,
                  onTap: () => onSelected(destination.tab),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _Destination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: isSelected,
      label: destination.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 56,
            minHeight: AppSizes.minTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? destination.activeIcon : destination.icon,
                  size: 22,
                  color: color,
                ),
                const SizedBox(height: 2),
                Text(
                  destination.label,
                  style: AppTypography.labelSm.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
