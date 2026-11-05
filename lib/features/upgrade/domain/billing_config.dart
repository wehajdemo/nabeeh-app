import 'package:flutter/foundation.dart';

/// Deployment settings for the billing backend.
abstract final class BillingConfig {
  /// Region the `syncEntitlement` Cloud Function is deployed to. Must match
  /// `functions/src/config.mjs`.
  static const String functionsRegion = 'us-central1';

  /// Where a subscriber manages or cancels the subscription.
  static String get manageSubscriptionUrl =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? 'https://apps.apple.com/account/subscriptions'
          : 'https://play.google.com/store/account/subscriptions';
}
