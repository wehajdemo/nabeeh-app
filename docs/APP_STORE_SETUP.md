# رفع نبيه على App Store

البناء يتم في **Codemagic** (أجهزة Mac سحابية)، فلا تحتاج جهاز Mac. مفاتيح Apple تبقى عندك وفي Codemagic فقط، ولا تُرفع على GitHub أبداً.

المعرّف التقني للتطبيق (Bundle ID): `com.rateby.rateby`

## 1. Apple Developer: معرّف التطبيق

[developer.apple.com/account](https://developer.apple.com/account) ← Certificates, Identifiers & Profiles ← Identifiers ← **+**

1. App IDs ← App ← Continue.
2. Description: `Nabeeh`، Bundle ID: **Explicit** ← `com.rateby.rateby`.
3. من Capabilities فعّل **Sign in with Apple** (و In-App Purchase مفعّل تلقائياً) ← Continue ← Register.

## 2. App Store Connect: إنشاء التطبيق

[appstoreconnect.apple.com](https://appstoreconnect.apple.com) ← Apps ← **+** ← New App

- Platform: iOS، Name: `نبيه` (لو كان محجوزاً جرّب `نبيه - ميزانية الراتب`)، Primary Language: Arabic
- Bundle ID: `com.rateby.rateby`، SKU: `nabeeh`

## 3. الاتفاقيات والحساب البنكي (ضروري للاشتراكات)

Business (أو Agreements, Tax, and Banking) ← وافق على **Paid Apps Agreement**، وأكمل بيانات البنك والضرائب. بدونها ما تشتغل الاشتراكات.

## 4. الاشتراكات (نبيه بلس)

التطبيق ← Monetization ← Subscriptions ← أنشئ مجموعة اسمها `Nabeeh Plus`، وداخلها اشتراكين **بنفس هذه المعرّفات بالضبط**:

| Product ID | المدة | السعر |
| --- | --- | --- |
| `rateby_plus_monthly` | شهر | 9 ر.س |
| `rateby_plus_yearly` | سنة | 67 ر.س |

لكل اشتراك: اسم ووصف بالعربي (Localization)، وصورة للمراجعة (لقطة شاشة تبويب الترقية: `store/ios/05-upgrade.png`).
وأضف **Introductory Offer**: Free، مدة 7 أيام، للمشتركين الجدد (التطبيق يعرض «7 أيام مجاناً»).

## 5. مفتاح App Store Connect لـ Codemagic

Users and Access ← Integrations ← App Store Connect API ← Team Keys ← **+**

- Name: `Codemagic`، Access: **App Manager** ← Generate.
- نزّل ملف `.p8` (ينزل **مرة وحدة فقط**، احفظه)، وسجّل **Issuer ID** و **Key ID**.
- لا ترسل هذا الملف لأحد ولا ترفعه على GitHub.

## 6. Codemagic

1. سجّل في [codemagic.io](https://codemagic.io) بحساب GitHub (`wehajdemo`).
2. Add application ← GitHub ← `wehajdemo/nabeeh-app` ← Flutter App ← يقرأ `codemagic.yaml` تلقائياً.
3. Team settings ← Integrations ← **Developer Portal** ← Connect:
   الاسم **`nabeeh_asc`** بالضبط، ثم Issuer ID و Key ID وارفع ملف `.p8`.
4. Team settings ← Code signing identities:
   - iOS certificates ← Generate certificate ← نوع **Apple Distribution**.
   - iOS provisioning profiles ← Fetch profiles ← أنشئ/اختر **App Store** profile لـ `com.rateby.rateby`.

## 7. Firebase

[console.firebase.google.com](https://console.firebase.google.com) ← مشروع `rateby-app-sa` ← Authentication ← Sign-in method ← **Apple** ← Enable ← Save.
(لتطبيق الآيفون يكفي التفعيل؛ حقول Services ID اختيارية.)

ثم يُنشر كود السيرفر المحدّث (التحقق من اشتراكات Apple + حذف الحساب):

```bash
cd admin/functions && npm install && cd .. && firebase deploy --only functions
```

بعد ما ينشر، اختيارياً: App Store Connect ← التطبيق ← App Information ← **App Store Server Notifications** ← Version 2 ← Production و Sandbox:
`https://us-central1-rateby-app-sa.cloudfunctions.net/appStoreNotifications`

لما يصير عندك رقم Apple ID للتطبيق (App Information ← Apple ID، رقم من 10 خانات) ضعه بدل الصفر في `APPLE_APP_ID` داخل `admin/functions/.env` وأعد النشر، عشان تُقبل مشتريات الإنتاج (TestFlight والمراجعة تشتغل بدونه).

## 8. البناء والرفع لـ TestFlight

إما من Codemagic: التطبيق ← **Start new build** ← workflow `Nabeeh iOS release`.
أو برفع tag يبدأ بـ `ios-` على GitHub (مثال: `ios-1.0.0-1`) فيبدأ البناء تلقائياً.

البناء ياخذ تقريباً 15–25 دقيقة، وبعدها يظهر في App Store Connect ← TestFlight بعد معالجة Apple (5–30 دقيقة).

## 9. صفحة المتجر والإرسال للمراجعة

App Store Connect ← التطبيق ← نسخة 1.0:

- **Screenshots** (6.9 إنش): الملفات في `store/ios/`.
- Description / Keywords / Support URL: `https://rateby-app-sa.web.app/legal/support.html`
- **Privacy Policy URL**: `https://rateby-app-sa.web.app/legal/privacy.html`
- App Privacy: البيانات المجموعة (معرّف الإعلانات لـ AdMob، البريد والاسم عند تسجيل الدخول، البيانات المالية في النسخة الاحتياطية، المشتريات).
- Age Rating، Category: Finance، Price: Free.
- **In-App Purchases and Subscriptions**: أضف الاشتراكين لهذه النسخة.
- Build: اختر البناء من TestFlight.
- App Review Information ← Notes، مثال:
  > تسجيل الدخول اختياري. للاشتراك: تبويب «نبيه بلس» ← اشترك ← المتابعة مع Apple. حذف الحساب: الإعدادات ← الحساب والنسخ الاحتياطي ← حذف الحساب.

ثم **Add for Review** ← **Submit**.
