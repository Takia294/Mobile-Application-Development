# LifeLink — Deployment Readiness Report

## Latest update (this pass)

1. **Fixed the Gradle build failure** you hit (`AAPT: error: resource
   color/notification_red ... not found`). The `AndroidManifest.xml`
   from the previous pass referenced `@color/notification_red` for the
   push-notification icon tint, but the matching color resource file
   was never created. Added
   `android/app/src/main/res/values/colors.xml` defining it. Re-run
   `flutter clean && flutter run`.

2. **Donor notifications now target only matching, available donors —
   for every request, not just High/Critical.** Previously, submitting
   a High/Critical request broadcast to literally every signed-in user
   (`targetUid: 'all'`), donor or not. Now `RequestDatabase.submitRequest`
   automatically queries `users` for donors who (a) have `isAvailable ==
   true`, (b) have a donor type matching the request (Blood Donor/Both
   for a blood request, Organ Donor/Both for an organ request), and for
   blood requests (c) have the matching blood group — then writes one
   personal notification straight to each of those donors, for *every*
   request regardless of urgency. The requester is never notified about
   their own request. The old blanket broadcast call in
   `emergency_request.dart` was removed since this is now handled
   centrally and correctly. A new Firestore composite index
   (`isAvailable`, `donorType`) was added to support this query.

---

## What was fixed in this pass

1. **`myprofile.dart` — stuck upload spinner.** `_pickProfileImage` and
   `_pickCertificate` set `isUploadingProfile` / `isUploadingCertificate`
   to `true`, then returned early (without resetting it) if
   `_auth.currentUser?.uid` came back null mid-upload (e.g. session
   expired). Fixed so the spinner always clears.

2. **Removed dead/duplicate code** — these files were empty or fully
   superseded by the `services/` layer and imported nowhere:
   - `donor_controller.dart`, `notification_controller.dart`,
     `profile_controller.dart`, `request_controller.dart` (all 0 bytes)
   - `auth_controller.dart` (superseded by `services/auth_service.dart`)
   - `firebase_service.dart` (superseded by the dedicated services)

3. **Reorganized into a real Flutter project layout** (`lib/screens`,
   `lib/models`, `lib/services`, `lib/routes`) matching the relative
   imports already used throughout the code (`../routes/screen_routes.dart`,
   `../services/...`, etc.) — the flat upload structure wouldn't compile.

## What was missing entirely (the app could not have shipped without these)

Everything below existed as *references in code comments* (e.g.
`push_notification_service.dart` describes a Cloud Function that never
existed; `AuthService` and screens assume Firestore rules and indexes
that were never defined) but none of it was actually present:

- **`pubspec.yaml`** — didn't exist. Built from every `package:` import
  actually used across the codebase. `google_sign_in` is intentionally
  pinned to `^6.2.1` — the 6.x `GoogleSignIn().signIn()` API is what
  `auth_service.dart` calls; version 7.x replaced it with a different
  async flow that would break sign-in silently if auto-upgraded.
- **`firestore.rules`** — didn't exist, meaning the project would only
  work in test mode (open to anyone) or be completely locked out in
  production mode. Without this, any signed-in user could grant
  themselves `role: admin` or approve their own donor certificate.
  Added rules covering `users`, `requests`, `notifications`, and
  `admin_stats`, including: users can't self-promote to admin or
  self-verify their certificate; request status can only be advanced to
  `Fulfilled`, not rewritten arbitrarily; notification `readBy` updates
  can only add the caller's own uid.
- **`firestore.indexes.json`** — didn't exist. Three of the app's
  queries combine a `where` with an `orderBy`/second field and **will
  throw `FAILED_PRECONDITION` in production** without a composite index:
  - `requests` filtered by `uid`, ordered by `createdAt` (My Requests,
    the request cooldown check)
  - `notifications` filtered by `targetUid whereIn`, ordered by
    `createdAt` (Notification screen)
  - `users` filtered by `donorType whereIn` + `bloodGroup ==`
    (Find Donors)
- **`storage.rules`** — didn't exist, same "wide open or fully locked"
  problem for profile photos / certificates. Added: owner-only write,
  5 MB cap, images only, any signed-in user can read.
- **The Cloud Function itself.** `push_notification_service.dart`'s doc
  comment says *"A Cloud Function (see `/functions/index.js`) listens
  for new `notifications` documents and sends a push"* — that function
  never existed anywhere in the uploads. Without it, `fcmToken` and the
  `all_users` topic subscription were being saved for nothing: **no
  push notification could ever have been sent**, only the in-app list
  worked. Added `functions/index.js` + `functions/package.json`.
- **Android permissions** (`AndroidManifest.xml`) — location, camera,
  media/photos, `POST_NOTIFICATIONS` (required at runtime on Android
  13+, which `PushNotificationService.init()` already calls but had no
  manifest entry backing it), and a `<queries>` block so `url_launcher`
  can open the phone dialer on Android 11+.
- **iOS permissions** (`Info.plist`) — `NSLocationWhenInUseUsageDescription`,
  `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, Sign in
  with Apple entitlement declaration, and background push modes. Without
  these the app crashes immediately on iOS the first time it touches
  location/camera/photos.
- **`firebase.json`** — wires `firestore.rules`, `firestore.indexes.json`,
  `storage.rules`, and `functions/` together so `firebase deploy` works
  in one command.

## Still required before a real production launch (can't be done from code alone)

1. Run `flutterfire configure` (or verify the existing `firebase_options.dart`
   project) and confirm `lifelink-a3cbe` is the Firebase project you
   intend to ship — the API keys in `firebase_options.dart` are already
   live values, not placeholders.
2. In Firebase Console → Authentication, enable Email/Password, Google,
   and Apple sign-in providers (the code calls all three).
3. Manually create the **first admin account**: register normally, then
   in Firestore change that one user's `role` field from `user` to
   `admin`. The security rules block anyone from doing this via the
   app itself (by design).
4. iOS: add the Sign in with Apple capability in Xcode, and add
   `GoogleService-Info.plist` (not generated here — pull it from the
   Firebase console for the iOS app).
5. Android: add `google-services.json` (same — pull from console).
6. `flutter pub get`, then `firebase deploy` (rules + indexes + functions)
   before first real users sign in.
7. Set an app icon / splash asset for `mipmap/ic_launcher` referenced in
   `AndroidManifest.xml` (currently whatever Flutter's default template
   icon is, unless already customized in your existing Android project).

## Notes on code quality already in place

The uploaded code already had a lot of prior bug-fixing done (visible
in the `BUG FIX:` comments throughout — donor type mismatches, broadcast
notification `isRead` bug, admin dashboard crashing on older docs missing
fields, stale/expired request handling, request-submission cooldown,
etc.). This pass focused on the remaining gaps: one real UI bug, dead
code cleanup, and the full deployment/security layer that had no
uploaded files at all.
