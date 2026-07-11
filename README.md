# LifeLink — Blood & Organ Donation App
Updated `lib/` folder — optimized, bug-fixed, and deployment-ready.

## 🐛 Critical bugs fixed

1. **Find Donor never showed any donors (the big one).**
   `find_donor.dart` queried `donorType whereIn ['Blood','Organ','Both']`,
   but `myprofile.dart` actually saves `'Blood Donor' | 'Organ Donor' |
   'Both' | 'None'`. The values never matched, so the donor list was
   always empty no matter how many people registered as donors.
   → Fixed by routing all donor queries through the new `DonorService`,
   which is now the single source of truth for donorType values.

2. **`registration.dart` saved `donorType: ""`** instead of the
   canonical `'None'`, which is inconsistent with what the rest of the
   app expects. → Fixed to save `'None'`.

3. **Broken logo asset paths.** `splash.dart` and `login.dart` pointed
   to `lib/screens/logo.png`, which is not a valid Flutter asset path
   (assets must live under a folder declared in `pubspec.yaml`, not
   inside `lib/`). This would show a broken image / fallback icon on
   every real device. → Logo moved to `assets/images/logo.png` and
   declared in `pubspec.yaml`; both screens updated, with graceful
   fallback icons kept.

4. **Duplicated, drifting hospital lists.** `emergency_request.dart`
   and `dashboard.dart` each hardcoded their own separate hospital
   name lists with no coordinates, so "nearby hospital" distances were
   fake placeholder text. → Unified into `HospitalService` (single
   list, real coordinates), and dashboard now computes genuine
   distances from the user's GPS position.

5. **Notification screen was 100% static/hardcoded** — could never
   show a real donor's activity. → Rewired to `NotificationService`,
   streaming real Firestore documents, same visual design.

## 🗺️ Free map integration (Find Donor)

Google Maps requires a billing-enabled API key even for the "free"
tier now, so this build uses **OpenStreetMap via `flutter_map`**,
which is completely free with no API key or billing account:

- Toggle between **List** and **Map** view (top-right icon in Find
  Donors).
- Donor pins are plotted from `latitude`/`longitude` saved in their
  Firestore profile.
- Your own location shows as a blue dot; tapping a donor pin opens
  the same contact sheet as the list.
- List results are sorted by real distance (via `geolocator`) once
  your location is available, with distance shown under each donor's
  name (e.g. "2.3 km away").
- **Call Now** button opens the phone dialer directly (`url_launcher`).

### How donors get a pin
- At **registration**, a "Share my location" checkbox (on by default)
  captures GPS coordinates non-blocking — registration still succeeds
  even if permission is denied.
- From **My Profile**, a new "My Location" card lets any user
  share/update their location at any time.
- Donors only appear in search once they also set a **Donor Type** in
  My Profile (Blood Donor / Organ Donor / Both) — this was already the
  intended design, now actually working.

## 🧱 New/completed files

| File | Purpose |
|---|---|
| `models/user_model.dart` | Canonical user profile shape (fixes field-name drift) |
| `models/donor_model.dart` | Read-model for donor search + map |
| `models/hospital_model.dart` | Hospital with real coordinates |
| `models/notification_model.dart` | Firestore-backed notifications |
| `services/location_service.dart` | GPS position + distance calculations (`geolocator`) |
| `services/donor_service.dart` | **The bug fix** — correct donorType filtering, distance sort |
| `services/hospital_service.dart` | Shared hospital list + nearest-hospital lookup |
| `services/notification_service.dart` | Stream/send notifications |
| `services/storage_service.dart` | Firebase Storage upload helper |
| `services/auth_service.dart` | Consolidated register/login/role logic (available for future use — screens still work standalone) |
| `services/request_service.dart` | Re-exports `RequestDatabase` (kept for import-path compatibility) |

**Removed:** the empty, unused `*_controller.dart` files
(`donor_controller`, `notification_controller`, `profile_controller`,
`request_controller`) and unused `auth_controller.dart` — none of the
screens ever imported them; their responsibilities are now covered by
the `services/` layer above. Removing dead scaffolding keeps the
codebase honest about what's actually wired up.

## 📦 Setup — dependencies

All required packages are in the included `pubspec.yaml`. Run:

```bash
flutter pub get
```

Key additions beyond what you already had:
- `flutter_map` + `latlong2` — free OpenStreetMap map rendering
- `geolocator` — GPS location + distance math
- `url_launcher` — tap-to-call donors

## 📍 Platform permissions (required for location + calling)

**Android** — add to `android/app/src/main/AndroidManifest.xml`
(inside `<manifest>`, above `<application>`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>
```

**iOS** — add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>LifeLink uses your location to show nearby donors and hospitals on the map.</string>
```

## 🔥 Firestore — rules & indexes (included, deploy before launch)

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

- `firestore.rules` — owners can edit their own profile/requests,
  admins have elevated access, everyone signed-in can read (needed for
  donor search + community request visibility).
- `firestore.indexes.json` — composite indexes required by:
  - `DonorService` (`donorType` + `bloodGroup` filter)
  - `NotificationService` (`targetUid` filter + `createdAt` order)
  - `RequestDatabase` (`uid` filter + `createdAt` order — likely
    already existed if "My Requests" was working for you before)

If you skip deploying indexes, Firestore will still work — but the
first time each query runs, the Flutter console will print a direct
link to auto-create the missing index; click it once and you're done.

## ✅ What was left as-is (already solid)

`admin_dashboard.dart`, `my_request.dart`, and `login.dart`'s core
flow were already well-built and correctly wired to `RequestDatabase`
— only touched where necessary (logo path, added a "request fulfilled"
notification hook). No need to reinvent working code.

## 🚀 Not yet wired (documented, not silently faked)

- Google/Apple social login buttons are still placeholders
  ("Coming Soon") — real OAuth needs Firebase console configuration
  specific to your app's bundle ID / SHA keys, which can't be
  generated from code alone.
- Admin broadcast notifications: `NotificationService.sendBroadcast()`
  is ready to call from the Admin Dashboard's UI whenever you want to
  add a "send alert to all users" button — not auto-wired to avoid
  guessing at UI you haven't asked for.
