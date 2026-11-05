import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/app.dart';
import 'package:rateby/features/account/application/account_providers.dart';
import 'package:rateby/features/account/data/firebase_account_service.dart';
import 'package:rateby/features/account/data/firestore_cloud_backup.dart';
import 'package:rateby/core/firebase/firebase_bootstrap.dart';
import 'package:rateby/core/links/link_launcher.dart';
import 'package:rateby/core/links/url_launcher_link_launcher.dart';
import 'package:rateby/features/ads/application/ads_providers.dart';
import 'package:rateby/features/ads/data/admob_ads.dart';
import 'package:rateby/features/ads/data/ad_pacing.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/budget/data/shared_prefs_budget_storage.dart';
import 'package:rateby/features/notifications/application/reminder_sync.dart';
import 'package:rateby/features/notifications/data/local_notifications_scheduler.dart';
import 'package:rateby/features/payments/application/payout_schedule_providers.dart';
import 'package:rateby/features/payments/data/firestore_payout_source.dart';
import 'package:rateby/features/payments/data/payout_schedule_caches.dart';
import 'package:rateby/features/upgrade/application/billing_providers.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';
import 'package:rateby/features/upgrade/data/cloud_functions_subscription_verifier.dart';
import 'package:rateby/features/upgrade/data/in_app_purchase_billing_client.dart';
import 'package:rateby/features/upgrade/data/shared_prefs_entitlement_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final firestore = await initFirestore();
  // Ads and subscriptions run on Android and iOS. Subscriptions are sold
  // through Google Play or the App Store and verified by a Cloud Function,
  // so Firebase must be present for billing.
  final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  final adsSupported = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android || isIos);
  final billingSupported = adsSupported;
  runApp(
    ProviderScope(
      overrides: [
        budgetStorageProvider.overrideWithValue(SharedPrefsBudgetStorage(prefs)),
        payoutScheduleCacheProvider.overrideWithValue(SharedPrefsPayoutCache(prefs)),
        entitlementCacheProvider.overrideWithValue(
          SharedPrefsEntitlementCache(prefs),
        ),
        linkLauncherProvider.overrideWithValue(const UrlLauncherLinkLauncher()),
        if (adsSupported) ...[
          adsAvailableProvider.overrideWithValue(true),
          adBannerBuilderProvider.overrideWithValue((_) => const AdMobBanner()),
          adNativeBuilderProvider.overrideWithValue((_) => const AdMobNative()),
          adServiceProvider.overrideWithValue(const AdMobService()),
          adPacingProvider.overrideWithValue(AdPacing(prefs: prefs)),
          adChoicesProvider.overrideWithValue(const AdMobChoices()),
        ],
        if (billingSupported)
          billingClientProvider.overrideWithValue(InAppPurchaseBillingClient()),
        if (billingSupported && firestore != null)
          subscriptionVerifierProvider.overrideWithValue(
            CloudFunctionsSubscriptionVerifier.firebase(
              store: isIos ? 'apple' : null,
            ),
          ),
        if (!kIsWeb && firestore != null) ...[
          accountServiceProvider.overrideWithValue(FirebaseAccountService()),
          cloudBackupProvider.overrideWithValue(FirestoreCloudBackup(firestore)),
        ],
        if (!kIsWeb)
          reminderSchedulerProvider.overrideWithValue(LocalNotificationsScheduler()),
        if (firestore != null)
          payoutRemoteSourceProvider.overrideWithValue(
            FirestorePayoutSource(firestore),
          ),
      ],
      child: const RatebyApp(),
    ),
  );
}
