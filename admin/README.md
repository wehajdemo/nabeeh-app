# راتبي — Admin dashboard (payout schedule)

Static web page (HTML + ES modules, **no build step**) that lets an admin edit the payout programs shown on the
app's *Payments* tab: add / edit / delete / reorder / hide, with a live "next payout" preview that applies the same
weekend rule as the app (Friday → Thursday, Saturday → Sunday).

It publishes **one Firestore document**, `config/payout_schedule`. The app reads that document at most once per 24 h
(plus pull-to-refresh) and keeps a local copy, so it also works offline and costs ~1 read per user per day.

```
admin/
  index.html  style.css  firebase-config.js   page, theme (same palette as the app), your Firebase web config
  js/schedule.js   pure logic: validation, weekend rule, preview, document shape (unit-tested)
  js/data.js       Firebase backend + in-memory demo backend (same interface)
  js/app.js        UI
  firestore.rules  firebase.json   security rules, hosting config
  test/schedule.test.mjs
  functions/       billing Cloud Functions (own package.json; `npm test` inside)
  legal/           generated privacy / terms / support pages  ←  ../assets/legal/legal.json
  scripts/build-legal.mjs   regenerates the pages (--check / --release)
```

## Try it now (no Firebase)

```bash
cd admin
python3 -m http.server 5173      # or: npx serve .
# open http://localhost:5173/index.html?demo=1        (?demo=empty starts with nothing published)
```

Demo mode keeps data in memory only and accepts any e-mail / password.

## Set up for real (Firebase)

**1. Project (console, once)** — create a project, then enable
**Firestore Database** (production mode) and **Authentication → Sign-in method → Email/Password**.

**2. Register a Web app** (Project settings → Your apps → `</>`) and paste its config into `admin/firebase-config.js`.
Put your project id in `admin/.firebaserc`.

**3. Deploy rules + dashboard**

```bash
npm i -g firebase-tools && firebase login
cd admin
firebase deploy --only firestore:rules,hosting
```

**4. Create the first admin** — either one command (needs
[Application Default Credentials](https://cloud.google.com/docs/authentication/provide-credentials-adc): `gcloud auth application-default login`):

```bash
cd admin && npm install
node scripts/bootstrap.mjs --project <project-id> --email you@example.com --password '<8+ chars>' --seed
```

(creates the Auth user if missing, writes `admins/<uid>`, and with `--seed` publishes the built-in list once),
or by hand: Authentication → Add user → copy the UID → Firestore → collection `admins` → document ID = UID, field `role: "admin"`.

**5. Sign in** at the hosting URL and publish changes from there.

**6. Connect the Flutter app** — in the Flutter project root:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project <project-id>     # overwrites lib/firebase_options.dart, adds google-services.json
flutter pub get
```

Android release builds need network access; Firebase's libraries already merge `INTERNET` into the manifest, but if a
release build can't download the schedule add `<uses-permission android:name="android.permission.INTERNET"/>` to
`android/app/src/main/AndroidManifest.xml`.

Optional hardening: in *Authentication → Settings → User actions* disable self-registration so only accounts you
create exist (the rules already refuse anyone not listed in `admins`).

### Security model

| Path | Read | Write |
| --- | --- | --- |
| `config/payout_schedule` | anyone (the app) | admins only; must contain just `programs` (1–50 items), `updatedAt == request.time`, `updatedBy`; never deletable |
| `admins/{uid}` | that user only (`get`) | nobody from clients — create it with the console or `bootstrap.mjs` |
| everything else | nobody | nobody |

Cost: the app does one document read per user per ≥24 h (+ pull-to-refresh). Publishing is 1 read + 1 write.

## Document format

`config/payout_schedule`:

```jsonc
{
  "updatedAt": <server timestamp>,      // forced by the rules to equal request.time
  "updatedBy": "admin@example.com",
  "programs": [
    {
      "id": "gov-salaries",             // stable; users' reminders are keyed by it — never change it
      "kind": "governmentSalary",       // governmentSalary | citizenAccount | socialSecurity | pension | studentStipend | other
      "category": "government",         // government | support | retireesAndStudents
      "title": "رواتب القطاع الحكومي",
      "provider": "الجهات المدنية والعسكرية",
      "certainty": "confirmed",         // confirmed | expected
      "dayOfMonth": 27,                 // 1–31 (shorter months use their last day)
      "windowEndDay": null,             // set → window "dayOfMonth … windowEndDay" instead of a fixed day
      "note": "", "windowNote": "",
      "active": true                    // false → kept in the dashboard, hidden from the app
    }
  ]
}
```

The app validates everything it downloads (`PayoutScheduleCodec`): a malformed program is skipped, and a document
without any valid program is ignored — the app keeps its cached or built-in list, so a bad publish cannot blank the tab.

## Behaviours worth knowing

* **Concurrent admins:** publishing runs in a transaction and refuses to overwrite a newer version
  («تم النشر من مشرف آخر»); reload and re-apply your change.
* **Draft vs published:** edits stay in the page until you press *نشر*; the page warns before closing with unpublished changes.
* **Delivery to users:** next app launch after 24 h since their last download, or immediately on pull-to-refresh.
* **Keep in sync with the app:** the built-in list (`DEFAULT_PROGRAMS`) and the date rules mirror
  `lib/features/payments/domain/payout_catalog.dart` and `payout_schedule_calculator.dart`; the Node test fails if the list drifts.

## Tests

```bash
cd admin
npm test                 # logic + Firebase adapter (against a fake SDK): schedule rules, validation, conflict handling
npm install && npm run test:rules   # security rules, in the Firestore emulator (needs Java 21+)
```

* `test/schedule.test.mjs` — weekend rule, windows, validation, document round-trip, parity with `payout_catalog.dart`.
* `test/firebase_backend.test.mjs` — load / save / conflict / admin check / auth, using an in-memory fake of the Firebase SDK.
* `test/rules.test.mjs` — who can read / write what (skipped automatically when no emulator is running).

The rules tests and the real Firebase SDK calls have not been run against a live project or the emulator here (no
access from my environment) — run `npm run test:rules` and do one real publish → app refresh on a test project before launch.

## Billing functions and legal pages (added later)

* `functions/` — `syncEntitlement` (callable; checks a Google Play purchase token and returns Plus status) and the
  optional `playNotifications` Pub/Sub handler. Setup is in `../docs/RELEASE_CHECKLIST.md` §2–3. Tests:
  `cd functions && npm install && npm test` (Google Play and Firestore are faked).
* `legal/` — static pages served by the same hosting site at `/legal/privacy.html` etc. Edit
  `../assets/legal/legal.json`, run `node scripts/build-legal.mjs`; `npm test` fails if a page is stale.
* Firestore: `subscriptions/*` and `entitlements/*` are written only by the function (Admin SDK) and closed to every
  client by `firestore.rules`.
