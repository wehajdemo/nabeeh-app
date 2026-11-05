# Before the first Play Store release

Everything below is outside the Dart code. None of it has been run from here (no Flutter SDK, no Firebase project,
no Play Console access) — treat each step as something to test once on a real device / test project.

## 1. Android project settings

`flutter create . --platforms=android` generates `android/`. Then:

**`android/app/build.gradle(.kts)`** — `flutter_local_notifications` needs desugaring and a recent SDK:

```kotlin
android {
    compileSdk = 35                      // 34+ required
    defaultConfig { minSdk = 23 }        // Firebase needs 23+
    compileOptions { isCoreLibraryDesugaringEnabled = true }
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

**`android/app/src/main/AndroidManifest.xml`** — inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

and inside `<application>` (so reminders survive a reboot):

```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

Reminders use *inexact* alarms, so no `SCHEDULE_EXACT_ALARM` permission is needed; a reminder can arrive a few
minutes late. The billing permission (`com.android.vending.BILLING`) is merged in by the `in_app_purchase` plugin.

**Ads (AdMob)** — inside `<application>` add your AdMob **app** id (the value below is Google's test id; the app
**crashes at launch without this tag**):

```xml
<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

Create a banner ad unit in AdMob and build releases with
`flutter build appbundle --dart-define=ADMOB_BANNER_ID=ca-app-pub-XXXX/YYYY`. Without the define the app uses
Google's **test** ads (never click real ads or use real ids while developing). In AdMob → *Privacy & messaging*,
create the **GDPR** message (and the US-states one if you sell outside Saudi) — the app already runs Google's consent
flow and offers "خيارات الإعلانات" in Settings when a region requires it. Plus subscribers see no ads.

Set the real `applicationId` now — it cannot change after publishing and is needed in steps 2–3.

## 2. Firebase (project, auth, functions)

1. Follow `admin/README.md` (project, Firestore, hosting, first admin, `flutterfire configure`).
2. **Authentication → Sign-in method → Anonymous: enable.** The app signs in anonymously only to call the billing
   function; no personal data is attached.
3. Upgrade the project to the **Blaze** plan (Cloud Functions need it; at this scale the cost is negligible).
4. Deploy the billing backend:

```bash
cd admin/functions && npm install && cd ..
firebase deploy --only functions,firestore:rules
# asks for PLAY_PACKAGE_NAME → your applicationId
```

The function region is `us-central1` (`admin/functions/index.js` ⇄ `BillingConfig.functionsRegion`). Change both
together if you move it.

## 3. Google Play Console — subscriptions and server access

**Products** (Monetize → Subscriptions). Product IDs must be exactly these (a test keeps app and server in sync):

| Product ID | Base plan | Price |
| --- | --- | --- |
| `rateby_plus_monthly` | monthly, auto-renewing | SAR 9 |
| `rateby_plus_yearly` | yearly, auto-renewing | SAR 67 |

Add a **free-trial offer of 7 days** (new customers) to each. The app takes the cheapest offer Play returns, which is
the trial for eligible users and the plain base plan for everyone else. Prices in Play Console are the real prices;
`PlusPlan` in the app only drives the text on screen — keep them equal.

Billing only works for an app uploaded to a Play track (internal testing is enough) and installed from Play.
Add yourself under *Setup → License testing* to buy without being charged.

**Letting the function ask Google about purchases**

1. Google Cloud console → enable **Google Play Android Developer API** for the Firebase project.
2. Play Console → *Users and permissions* → invite the function's service account — for 2nd-gen functions that is
   `<PROJECT_NUMBER>-compute@developer.gserviceaccount.com` (shown under the function's *Details → Service account*).
   Grant **View financial data** and **Manage orders and subscriptions**. Permission changes can take hours to apply.

**Optional — real-time notifications** (refunds and cancellations reach users sooner; without it the app still
re-checks on every start/resume, at most every 15 minutes):

1. Create a Pub/Sub topic named `play-rtdn`.
2. Give `google-play-developer-notifications@system.gserviceaccount.com` the *Pub/Sub Publisher* role on it.
3. Play Console → Monetize → *Monetization setup* → Real-time developer notifications → topic
   `projects/<project-id>/topics/play-rtdn` → send a test notification.

## 4. Privacy policy, terms, support

* Text: `assets/legal/legal.json` (single source for the in-app screens **and** the web pages).
* **Fill in** `meta.developerName` and `meta.supportEmail`, check `effectiveDate`, then:

```bash
cd admin
node scripts/build-legal.mjs --release   # fails while placeholders remain
npm test                                  # fails if a page is out of date
firebase deploy --only hosting
```

* Pages: `https://<project>.web.app/legal/privacy.html`, `terms.html`, `support.html` (add `.en.html` for English).
  Paste the privacy URL into Play Console → *App content → Privacy policy*; use the support URL / email on the store listing.
* The text describes the app **as it is today: AdMob banner ads for free users, no analytics**.
  `features.ads` in `legal.json` and `AppInfo.hasAds` are both `true` (a test fails if they differ). To ship a build
  without ads, set both to `false` and rebuild the pages.
* It is a reasonable starting text, **not legal advice**. Have it reviewed (Saudi PDPL, consumer rules) before launch.

## 5. Data-safety form (Play Console → App content) — what the code actually does

| Data | Collected? | Notes |
| --- | --- | --- |
| Salary, expenses, goals, commitments | No (stays on device) | Never sent anywhere |
| Purchase history (purchase token) | Yes — sent to your server | For subscription verification; required to provide the feature |
| App/device identifiers | Yes | Firebase anonymous user ID; **advertising ID** (AdMob, shared with Google for advertising); Firebase may process IP address |
| Approximate/other usage data | Yes (by AdMob) | Ad interactions, diagnostics — declare under advertising/analytics, shared with Google |
| Personal info, location, contacts | No | |
| Data encrypted in transit | Yes (HTTPS) | Local data is **not** encrypted at rest (see README → limitations) |

Also tick **“Contains ads”** under *App content → Ads*. Verify the answers against the final build (especially if you add analytics).

## 6. Claims in the app text

* Ad removal for Plus is real. WhatsApp support was removed from the pitch (it now promises priority e-mail replies —
  only keep that if you will actually answer Plus subscribers first).

## 7. On-device test pass (nothing below has run yet)

* Buy monthly and yearly with a license-tester account → Plus unlocks, Upgrade tab shows the active card.
* Cancel in Play → still Plus until the period ends → then locked again after the next app start.
* Reinstall → *Restore previous purchases* → Plus returns.
* Airplane mode right after paying: purchase stays unacknowledged, next launch delivers it and unlocks Plus.
* Notifications: allow permission, turn on a payout alert, set the device clock near 18:00 the evening before a payout.
* Export PDF opens correctly with Arabic text; CSV opens in Excel with Arabic headers.
* Free account: a banner appears above the bottom bar (test ad); after subscribing it disappears.
* Free account: 4th goal → upgrade prompt; daily-limit alert toggle → upgrade prompt; export → upgrade prompt.
* Dark mode: Settings → المظهر → داكن; walk every tab, the add-expense screen, all sheets/dialogs, the legal pages and the Upgrade tab. Look for unreadable text, white flashes and the hero cards. Then switch the phone between light/dark with "حسب الهاتف" selected.

## Ad units (one per format)

Create five ad units in AdMob and pass each id at build time (test ids are the defaults):

```
flutter build appbundle \
  --dart-define=ADMOB_BANNER_ID=... --dart-define=ADMOB_INTERSTITIAL_ID=... \
  --dart-define=ADMOB_REWARDED_ID=... --dart-define=ADMOB_NATIVE_ID=... \
  --dart-define=ADMOB_APP_OPEN_ID=...
```

Pacing lives in `AdConfig` (interstitial every 3rd expense, 3 min gap, 3/day; app-open once a day after 4 h away).

Real ad-unit ids live in `config/release.defines.json` (never used by debug runs, which keep Google's test ids):

```
flutter build appbundle --dart-define-from-file=config/release.defines.json
```

## iPhone (iOS)

* Bundle id `com.rateby.rateby`; AdMob iOS app id is in `ios/Runner/Info.plist` (`GADApplicationIdentifier`), iOS ad units in
  `config/release.ios.defines.json`; Firebase iOS app is registered (options in `lib/firebase_options.dart`).
* Build needs macOS: use Codemagic with `codemagic.yaml` (no Mac), or `flutter build ipa --dart-define-from-file=config/release.ios.defines.json` on a Mac.
* Needs an Apple Developer account (99 USD/year) and the app created in App Store Connect.
* Step-by-step App Store setup (Arabic): **docs/APP_STORE_SETUP.md**.
* Subscriptions on iOS use StoreKit 2 with the same product ids (`rateby_plus_monthly`, `rateby_plus_yearly`). The app sends the
  signed transaction (JWS) to `syncEntitlement` with `store: "apple"`; the function checks Apple's signature against
  `admin/functions/certs/AppleRootCA-G3.cer` (no App Store Connect key needed). Sandbox (TestFlight, App Review) is accepted;
  production purchases need `APPLE_APP_ID` (numeric Apple ID) in `admin/functions/.env`; `0` = sandbox only.
* Renewals, expiry and refunds reach the server through App Store Server Notifications V2: set the URL of the
  `appStoreNotifications` function in App Store Connect. Without it, the app still updates on launch.
* Sign in with Apple is offered on iPhone (Apple guideline 4.8); Google sign-in appears there only when
  `GOOGLE_IOS_CLIENT_ID` is set in Codemagic. Settings → حذف الحساب deletes the account (guideline 5.1.1(v));
  the `deleteUserData` function removes its backup, entitlement and purchase records.
* iOS 15 minimum (StoreKit 2).

## Sign-in and cloud backup

* Optional sign-in (Apple on iPhone, Google) is required only to subscribe. Subscribers' purchases are keyed by the Firebase account uid, so they follow the person to a new phone.
* Signed-in users get an automatic copy of their budget data at `users/{uid}/backup/latest` (rules in `admin/firestore.rules`). Privacy policy and Data safety already describe it.
* Setup: Firebase console → Authentication → Apple → Enable, and Google → Enable. Android: register SHA-1 of the upload key, the debug key **and the Play App Signing key** (Play Console → Setup → App signing), then re-download `google-services.json`. iOS (Google, optional): set `GOOGLE_IOS_CLIENT_ID` in `codemagic.yaml`; the build adds the URL scheme and the define.
