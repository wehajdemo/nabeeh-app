# نبيه | Nabeeh — Google Play listing

Package: `com.rateby.rateby` (technical id, never shown to users) · Version 1.0.0 (1) · Category: Finance (المالية) · Free, with ads and an optional in-app subscription · Developer name: **نبيه تك / Nibras Tech** (use the name already on the developer account) · Support: nibras.tech.sa@gmail.com

## Arabic (ar) — اللغة الأساسية

**الاسم (≤30):** نبيه | مخطط الراتب والميزانية

**وصف قصير (≤80):** اعرف كم تصرف يومياً حتى الراتب القادم، وخطط ميزانيتك بسهولة

**الوصف الكامل:**
نبيه تطبيق يساعدك توزّع راتبك على أيام الشهر بدون تعقيد.
أدخل راتبك وموعد نزوله والتزاماتك الثابتة، ويحسب لك التطبيق كم تقدر تصرف كل يوم حتى الراتب القادم.

أبرز المميزات:
• الحد اليومي: يعرض لك المتاح للصرف اليوم، ويتحدث مع كل مصروف تسجله
• تسجيل المصروف بثوانٍ، مع ملاحظة اختيارية (بقالة، قهوة، بنزين…)
• العد التنازلي للراتب: كم باقي على الراتب القادم
• الالتزامات الثابتة: الإيجار، الأقساط، الاشتراكات، وغيرها
• أهداف الادخار: تابع تقدمك نحو كل هدف
• مواعيد صرف الدعم والرواتب: تنبيهات تذكّرك قبل موعد النزول
• تصدير تقريرك بصيغة PDF أو CSV
• يدعم العربية بالكامل، والوضع الداكن
• بياناتك المالية (الراتب والمصاريف والأهداف) تبقى على جهازك

نبيه بلس (اشتراك اختياري):
• بدون إعلانات
• تنبيهات الحد اليومي
• أهداف غير محدودة وتصدير التقارير دائماً
• تجربة مجانية 7 أيام، ثم 9 ر.س شهرياً أو 67 ر.س سنوياً
تقدر تلغي الاشتراك في أي وقت من إعدادات Google Play.

النسخة المجانية تعرض إعلانات، ويمكنك تصدير تقريرك مرة واحدة بمشاهدة إعلان مكافأة.

## English (en-US)

**Name:** Nabeeh – Salary Budget Planner

**Short:** Know how much you can spend each day until your next payday

**Full:**
Nabeeh splits your salary across the days until your next payday. Enter your salary, payday and fixed commitments, and the app shows your daily spending limit and updates it with every expense you log.

• Daily allowance and payday countdown
• Log an expense in seconds, with an optional note (groceries, coffee, fuel…)
• Fixed commitments (rent, installments, subscriptions)
• Savings goals with progress tracking
• Payout-date reminders
• PDF / CSV report export
• Full Arabic (RTL) support and dark mode
• Your financial data stays on your device

Nabeeh Plus (optional subscription): no ads, daily-limit alerts, unlimited goals and exports. 7-day free trial, then SAR 9/month or SAR 67/year. Cancel anytime in Google Play. The free version shows ads; you can also export one report by watching a rewarded ad.

## Subscriptions to create in Play Console (Monetize → Subscriptions) — only after the first AAB is uploaded

| Product ID (exact) | Base plan | Price | Offer |
| --- | --- | --- | --- |
| `rateby_plus_monthly` | monthly, auto-renewing | SAR 9 | 7-day free trial, new customers only |
| `rateby_plus_yearly` | yearly, auto-renewing | SAR 67 | 7-day free trial, new customers only |

(The product ids keep the old name because they are hard-coded in the app and in the server function.)

## App content answers

- **Ads:** Yes, contains ads (AdMob).
- **Privacy policy URL:** https://rateby-app-sa.web.app/legal/privacy.html (live)
- **Terms:** https://rateby-app-sa.web.app/legal/terms.html · **Support page:** https://rateby-app-sa.web.app/legal/support.html
- **App access:** no login; everything is available without an account.
- **Target audience:** 18+ (financial app; not directed to children).
- **Content rating:** no violence/sex/gambling/user-generated content → "Everyone". Financial category: does not facilitate loans, trading or money transfers.
- **Data safety:**
  - Salary, expenses, notes, goals, commitments: not collected (stay on the device).
  - Purchase history: collected, sent to our server for subscription verification, required for the subscription.
  - Device or other IDs: collected — Firebase anonymous user id (subscription check only) and advertising ID (AdMob, shared with Google for advertising).
  - App interactions / diagnostics: collected by AdMob, shared for advertising.
  - Data encrypted in transit: Yes. Users can request deletion by e-mail (nibras.tech.sa@gmail.com) or in-app "Reset account".
- **Advertising ID declaration:** Yes, used for advertising (AdMob).
- **Financial features declaration:** budgeting only; no loans, banking, investment or payments.
- **Ads policy note:** no ad appears over the "save expense" action; interstitials are capped (see `AdConfig`).

## Assets (all generated, in `store_screenshots/`)

- App icon 512×512: `app_icon_512.png`
- Feature graphic 1024×500: `feature_graphic_1024x500.png`
- Phone screenshots (Android, 1440×2880): `android/01-home.png` … `06-settings.png`
- App Store (iPhone 6.9", 1320×2868) for later: `ios/`

## Console steps

1. Create app → name "نبيه", default language Arabic, App, Free, accept declarations.
2. Store listing, App content (answers above).
3. Testing → Internal testing → Create release → upload `nabeeh-1.0.0+1.aab` (accept Play App Signing; our file is the upload key) → add testers.
4. Monetize → Subscriptions: create the two products above and activate them.
5. Link the server function (see PUBLISH_RUNBOOK.md, "Subscription server link").
6. Test purchases from the Play-installed build, then promote to Closed/Production.
   Personal developer accounts created after Nov 2023 must first run a closed test with at least 12 testers for 14 days.
