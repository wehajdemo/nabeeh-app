import 'package:flutter/material.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/settings/application/settings_state.dart';
import 'package:rateby/features/settings/presentation/settings_strings.dart';
import 'package:rateby/features/settings/presentation/widgets/settings_section.dart';

/// Salary, fixed commitments and payday — each opens its own editor.
class FinancialDataSection extends StatelessWidget {
  const FinancialDataSection({
    required this.state,
    required this.onEditSalary,
    required this.onEditCommitments,
    required this.onEditPayday,
    super.key,
  });

  final SettingsState state;
  final VoidCallback onEditSalary;
  final VoidCallback onEditCommitments;
  final VoidCallback onEditPayday;

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    final titles = state.commitmentTitles;

    return SettingsSection(
      icon: Icons.account_balance_wallet_outlined,
      title: SettingsStrings.basicsSection,
      children: [
        SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.payments_outlined,
              title: SettingsStrings.salaryTitle,
              subtitle: SettingsStrings.salarySubtitle,
              trailing: _Amount(
                amount: profile.netSalary,
                color: AppColors.primary,
              ),
              onTap: onEditSalary,
            ),
            SettingsTile(
              icon: Icons.receipt_long_outlined,
              iconColor: AppColors.tertiary,
              title: SettingsStrings.commitmentsTitle,
              subtitle: titles.isEmpty
                  ? SettingsStrings.commitmentsNone
                  : SettingsStrings.commitmentsSummary(titles),
              trailing: _Amount(
                amount: profile.commitmentsTotal,
                color: AppColors.onSurface,
              ),
              onTap: onEditCommitments,
            ),
            SettingsTile(
              icon: Icons.event_repeat_outlined,
              iconColor: AppColors.secondary,
              title: SettingsStrings.paydayTitle,
              subtitle: profile.payDay == BudgetProfile.defaultPayDay
                  ? SettingsStrings.paydayGovernmentNote
                  : SettingsStrings.paydayCustomNote,
              trailing: Text(
                SettingsStrings.paydayValue(profile.payDay),
                style: AppTypography.labelLg.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: onEditPayday,
            ),
          ],
        ),
      ],
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({required this.amount, required this.color});

  final Money amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CurrencyAmount(
      amount: amount,
      amountStyle: AppTypography.headlineSm.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      symbolStyle: AppTypography.labelSm.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}
