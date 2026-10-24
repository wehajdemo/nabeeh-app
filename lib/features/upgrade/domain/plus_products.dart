import 'package:rateby/features/upgrade/domain/plus_plan.dart';

/// Google Play subscription product IDs. They must match the products
/// created in Play Console and `functions/src/products.mjs` (a test keeps
/// both lists identical).
abstract final class PlusProducts {
  static const String monthlyId = 'rateby_plus_monthly';
  static const String yearlyId = 'rateby_plus_yearly';

  static const Set<String> all = {monthlyId, yearlyId};

  static String idFor(PlusPlanType plan) => switch (plan) {
        PlusPlanType.monthly => monthlyId,
        PlusPlanType.yearly => yearlyId,
      };

  /// `null` for a product that is not ours.
  static PlusPlanType? planFor(String productId) => switch (productId) {
        monthlyId => PlusPlanType.monthly,
        yearlyId => PlusPlanType.yearly,
        _ => null,
      };
}
