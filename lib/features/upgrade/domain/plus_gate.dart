/// Features that need "نبيه بلس".
enum PlusFeature { export, unlimitedGoals, dailyLimitAlerts }

/// Thrown when a Plus-only action is attempted without a subscription.
class PlusRequiredException implements Exception {
  const PlusRequiredException([this.feature]);

  final PlusFeature? feature;

  @override
  String toString() => 'PlusRequiredException($feature)';
}

/// What the free plan includes. Change the limits here only.
abstract final class PlusLimits {
  /// Savings goals a free user may have; Plus is unlimited.
  static const int freeGoalCount = 3;
}
