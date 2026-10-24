import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';

/// Salary, payday and fixed commitments.
abstract interface class ProfileRepository {
  /// `null` until onboarding is completed.
  Stream<BudgetProfile?> watchProfile();

  Future<void> completeSetup(BudgetProfile profile);
  Future<void> updateNetSalary(Money salary);
  Future<void> updatePayDay(int day);
  Future<void> addCommitment(CommitmentDraft draft);
  Future<void> removeCommitment(String id);

  /// Wipes every record and returns the app to first-run state.
  Future<void> resetAll();
}
