# نبيه — Nabeeh (Flutter)

Salary-cycle budgeting app for Saudi Arabia. **All screens are built:**
Onboarding (3 steps) · Home · Add Expense · Goals (with balances) · Payments (payout dates) · Upgrade (نبيه بلس) ·
Settings · Privacy policy / Terms / Support. Plus: local reminders, PDF/CSV export, optional Google sign-in with a
cloud backup, and Google Play subscriptions verified by a Cloud Function.

> **Status:** `flutter analyze` reports no errors or warnings and all 223 Flutter tests pass (2 November 2026).
> Billing, notifications and the Cloud Function are covered by the on-device pass in
> **docs/RELEASE_CHECKLIST.md**, which is the list to follow before shipping.
>
> The app started under the working name Rateby, which remains in technical ids only (`rateby` package,
> `com.rateby.rateby`, the `rateby_plus_*` product ids and the Firebase project).

## Run it

```bash
cd nabeeh_app
flutter pub get
flutter analyze
flutter test
flutter run
dart format .
```

Requires Flutter ≥ 3.27 (Dart ≥ 3.6) and `flutter_riverpod` 2.x (not 3.x).

## Firebase

Firebase is optional at runtime: until it is configured the app silently uses the built-in payout list and reports
"subscription unavailable" (nobody can get Plus without the server check).
Setup (project, rules, first admin, `flutterfire configure`) is a short checklist in **admin/README.md**; the Play
Console / functions / legal-pages steps are in **docs/RELEASE_CHECKLIST.md**.

The app reads one document, `config/payout_schedule` (at most once per 24 h, cached). Signing in with Google is
optional and required only to subscribe; the app then calls the `syncEntitlement` function, and clients never read or
write purchase data directly.

## Subscriptions (نبيه بلس)

```
Play Billing ─ in_app_purchase ─▶ PlayBillingGateway ─ purchase token ─▶ syncEntitlement (Cloud Function)
                                                                          │ asks Google Play (subscriptionsv2)
     isPlusProvider ◀─ entitlementProvider (cached) ◀─ {active, plan, expiresAt} ◀┘  acknowledges, stores per account
```

* A purchase is acknowledged only after the server confirmed it; if the server is unreachable it stays open and the
  store re-delivers it on the next launch.
* The app re-checks on start/resume (≥15 min apart, only for people who ever subscribed). Offline, the cached
  entitlement works until its end date.
* One purchase unlocks one account at a time; signing in with the same Google account brings it back on a new phone.
* **What Plus gates** (one place to change: `features/upgrade/domain/plus_gate.dart`): more than
  `PlusLimits.freeGoalCount` (3) goals, PDF/CSV export, daily-limit alerts. Payout-date alerts stay free.
  Ads are removed for subscribers (`showAdsProvider`).
* The cached entitlement lives in `shared_preferences`, so a rooted device could edit it; it expires at the stored
  end date and is overwritten by the next server check. Server-side actions (none today) must never trust it.

## First launch

The app starts on **Onboarding** (salary → fixed commitments → payday). Finishing it stores the profile and the
app gate switches to the main shell on its own; **Settings → تصفير الحساب** wipes everything and returns to
Onboarding. Data is saved on the device (`shared_preferences`, plain JSON — see *Known limitations*).

## Architecture (feature-first, 3 layers per feature)

```
lib/
  main.dart, app.dart              entry · MaterialApp (ar-SA, RTL) · AppGate (onboarding vs. shell)
  core/
    theme/        AppColors (light+dark `AppPalette`) · AppTypography · AppSpacing(+AppRadius, AppSizes) · AppShadows · AppTheme
    constants/    AppStrings (shared copy) · AppInfo
    money/        Money (integer halalas)
    utils/        MoneyFormatter · ArabicText · DateMath · AmountTextInputFormatter
    navigation/   AppTab + NavigationController
    providers/    clockProvider (injectable "now")
    widgets/      reusable kit: AppCard, IconBadge, InfoPill, StatusChip, AppProgressBar, PrimaryButton,
                  AppTextField, AppSwitch, SettingsTile/Group, ChoiceChipBar, StepProgressBar,
                  DashedBorderButton, app bottom sheet, AppToast, ScreenBody, ...
  features/
    account/      optional Google sign-in (AccountService) · cloud backup in Firestore (CloudBackup) · sign-in prompt
    budget/       shared kernel
                  domain/       entities (BudgetProfile, SavingsGoal, FixedExpense, AppSettings, ...),
                                repository interfaces (Budget / Profile / Goals / Settings),
                                LogExpense use case, DailyLimitCalculator
                  data/         LocalBudgetStore  <- swap for Drift/REST here; BudgetStorage (+ SharedPrefs),
                                StoreDataCodec (JSON)
                  application/  providers: DI root + shared streams (snapshot, profile, goals, settings)
                  presentation/ shared widgets: commitment tile/form, salary field/sheet, payday picker/sheet
    onboarding/   OnboardingController (3-step state machine) + screen/step widgets
    home/         HomeController, HomeScreen -> HomeBody -> cards
    add_expense/  AmountInput (pure keypad rules), controller, keypad screen
    goals/        GoalsController, GoalsScreen, goal card / form sheet
    payments/     domain: PayoutProgram, PayoutCatalog (built-in fallback), PayoutScheduleCalculator (weekend rule),
                          PayoutSchedule + PayoutScheduleCodec (validating decoder), repository interfaces
                  data:   RemotePayoutScheduleRepository (cache-first, refresh if >24 h), FirestorePayoutSource,
                          SharedPrefsPayoutCache
                  application: PaymentsController (+ filter provider), payoutScheduleProvider, screen / payout cards
    settings/     SettingsController, SettingsScreen, sections, commitments sheet, reset flow
    upgrade/      PlusPlan pricing · PurchaseGateway boundary · PlayBillingGateway (in_app_purchase) ·
                  SubscriptionVerifier (Cloud Function) · entitlement cache/refresh · plus_gate · UpgradeScreen
    notifications/ ReminderPlanner (pure) · ReminderScheduler · flutter_local_notifications adapter · ReminderSync
    ads/          showAdsProvider (free users only) · AdBannerSlot · AdMob banner + Google consent (UMP)
    export/       BudgetReport · CsvBuilder · PdfReportGenerator (Arabic RTL) · share_plus · Plus-gated flow
    legal/        LegalContent (parses assets/legal/legal.json) · Privacy / Terms / Support screens
    shell/        MainShell (IndexedStack, 5 tabs), AppTopBar, AppBottomNav
    profile/      UserProfile placeholder (name)
admin/            web dashboard for the payout schedule (see admin/README.md)
  functions/      Cloud Functions: syncEntitlement (Play verification) + optional Play notifications (Node tests)
  legal/          generated static privacy / terms / support pages (source: assets/legal/legal.json)
assets/legal/     single source of the legal text (Arabic + English)
docs/             RELEASE_CHECKLIST.md
```

Rules the code follows:

* **UI is dumb.** Widgets are `StatelessWidget`; screens are `ConsumerWidget`s that map controller state to
  widgets and forward callbacks. Local `State` is used only for ephemeral UI (text controllers, form
  validation display, "is busy" flag).
* **Logic lives outside widgets.** Date math → `SalaryCycle`, `PayoutScheduleCalculator`; limits →
  `DailyAllowance`, `DailyLimitCalculator`; keypad rules → `AmountInput`; screen state → controllers.
* **One data source, many readers.** Repositories are interfaces; `LocalBudgetStore` implements all four.
  Changing a goal or salary updates the daily limit on Home automatically.
* **No hardcoded values.** Colors, type, spacing, radii, shadows and copy come from `core/` or each feature's
  `*_strings.dart`.

Tests (`test/`): money, salary cycle, daily allowance, daily-limit calculator, keypad, add-expense, onboarding,
goals, payout schedule, payout schedule codec + remote repository (fallback, cache, staleness, offline),
payments controller, persistence/codec, and widget flows (onboarding → home, all tabs, reset).
Also: goal balances and payday crediting, reminder planner/sync, report/CSV/PDF/export gating, billing gateway,
server-response parsing, entitlement refresh, Plus limits, legal content and screens, cloud backup sync.
Dashboard logic + Firebase adapter + legal pages: `cd admin && npm test`; billing function: `cd admin/functions && npm install && npm test`;
security rules (emulator): `cd admin && npm run test:rules`.
App-side Firestore source is tested with `fake_cloud_firestore`.

## Decisions where the design and reality disagree

| Design said | What the code does |
| --- | --- |
| Daily limit 85 / 62 left, hard-coded | Computed: `(salary − commitments − goal deductions) ÷ cycle days`, rounded down. Demo data gives 221 / 198 left. |
| Onboarding 3 sample commitments (3,450) | Kept as editable/removable starting examples. |
| "محدّث تلقائياً" on payout dates | Dates come from the admin dashboard (`config/payout_schedule`) once Firebase is set up, with the built-in catalog as fallback. The banner shows **آخر تحديث <date>** for a published schedule and **جدول إرشادي** for the built-in one. Verify the dates against official sources before publishing. |
| Hijri dates, "الدفعة 83" | Omitted (not computed / would go stale). |
| Friday/Saturday payout examples | Weekend rule applied properly (Fri → Thu, Sat → Sun) and flagged on the card. |
| "مشفرة"، "متوافق مع لوائح ساما" | Reworded to "محفوظة على جهازك". Data is **not encrypted** and no compliance claim is made. |
| "ربط تلقائي بالرسائل البنكية" | Removed from the Plus pitch — not implemented. |
| Testimonial on the Upgrade page | Omitted (invented endorsement). |
| "دعم عبر واتساب" in the Plus pitch | Removed (no such channel); reworded to priority e-mail replies. |
| Plus price 9.99 in Settings vs 9 elsewhere | One source: `PlusPlan` (9 ر.س/شهر, 67 ر.س/سنة → 38% saving, computed). |

## Known limitations

* **On-device checks:** the billing, notification and export paths need the on-device pass in
  `docs/RELEASE_CHECKLIST.md` §7.
* **Dashboard sign-in is Firebase Auth + an `admins/{uid}` allow-list.**
* **Reminders** are one-shot local notifications for the next few days (payout: evening before + morning of; daily
  limit: 09:00), rebuilt on every app start/resume and whenever settings, goals or the schedule change. They use
  inexact alarms (can be minutes late) and are only refreshed when the app is opened; if it is not opened for more
  than ~3 days the queued ones run out. No notifications on web.
* **Ads:** one AdMob banner above the bottom bar for free users (Android and iOS, Google test ads until you set real ids
  — see the checklist). Not implemented: interstitials/rewarded ads, ad-free grace on first launch.
* **Dark mode** (Settings → المظهر: follow phone / light / dark) is built from two explicit palettes
  (`AppPalette.light` / `.dark`). Colors are read from a global (`AppColors.x`), so switching rebuilds the whole
  app (the `MaterialApp` is keyed on the brightness) and any open sub-page is closed. The hero cards (daily
  allowance, goals summary, Plus promo) keep their emerald look in both modes on purpose. Contrast of the text/background
  pairs is checked in `test/core/theme/app_palette_test.dart`, but nobody has looked at every screen in dark mode on
  a device yet — expect to tweak a few spots. The legal pages are a starting text, not legal advice.
* **Storage** is `shared_preferences` JSON on the device — fine for a prototype, not encrypted. For production
  swap in Drift/Isar (+ `flutter_secure_storage` for sensitive values) behind the same repository interfaces.
  Signed-in people get a copy in Firestore that follows them to a new phone; without signing in, losing the phone
  loses the data.
* **User name** on Home is a placeholder (`features/profile`).
* Expenses older than 62 days are pruned when saving (only today's spending affects the limit). Export covers the
  current salary cycle only.
* Goal balances are credited on payday when the app is next opened (up to 24 missed paydays); nothing is credited
  retroactively for paydays before the goal existed.
