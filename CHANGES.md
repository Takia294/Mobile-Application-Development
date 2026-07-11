# LifeLink — Full Project Update Log

Replace your `lib/` folder with this one (and add `firestore.rules` to
your project root), then hot-restart. No new pubspec dependencies were
added — everything below uses packages you already had.

## Real bugs fixed

1. **My Profile bottom nav — notification tab was dead**
   `myprofile.dart` had a 5-icon bottom nav, but the `onTap` switch was
   missing `case 2`, so tapping the notifications icon did nothing.

2. **Admin dashboard — two stat widgets were permanently stuck at 0**
   `donations` and `complaints` Firestore collections were read by
   `admin_dashboard.dart` but nothing in the entire app ever wrote to
   them, so "Monthly Donations" chart and "Pending Complaints" card
   were dead UI showing fake zeros forever.
   - Monthly Donations chart now derives real numbers from `requests`
     where `status == 'Fulfilled'`, grouped by month.
   - "Pending Complaints" replaced with **"Critical Requests"** — a
     real, live, actionable number pulled from actual request data.

3. **Broadcast notification system existed but nothing ever called it**
   `NotificationService.sendBroadcast()` was fully implemented and the
   Notification screen had a whole "urgent" banner UI for it — but no
   screen anywhere ever triggered it. For a blood donation app, this is
   the core feature.
   - Submitting a **High/Critical** emergency request now broadcasts an
     urgent alert to all users automatically.
   - Admin Dashboard now has a working **"Send Alert"** button (top-right,
     megaphone icon) to manually broadcast announcements/events to
     everyone.

4. **Broadcast notifications shared one global "read" flag**
   The old `isRead: bool` field lived on the notification document
   itself. For broadcasts (`targetUid == 'all'`), that meant if *any one
   user* tapped a notification or hit "Mark all as read", it silently
   marked that notification read **for every other user too**.
   - Replaced with a `readBy: List<String>` field (per-user read
     tracking) across `notification_model.dart`, `notification_service.dart`,
     and `notification.dart`. Each user's read state is now independent.

5. **"Forgot Password" was a fake button**
   It just showed a "Coming Soon" snackbar. Now it opens a dialog and
   sends a real Firebase password-reset email via
   `FirebaseAuth.sendPasswordResetEmail`.

6. **Google/Apple login buttons removed**
   They were non-functional placeholders ("Coming Soon" snackbars) with
   no OAuth wired up anywhere. Rather than ship fake buttons, they were
   removed. (Real Google/Apple Sign-In needs platform-specific setup —
   `google-services.json` changes, signing configs, etc. — happy to wire
   this up properly if you want it later.)

## Code quality / consistency

7. **`login.dart` and `registration.dart` now use `AuthService`**
   Previously both screens duplicated the exact same
   Firebase Auth + Firestore user-document logic inline (and slightly
   differently from each other). They now both go through the existing
   `AuthService.loginAndGetRole()` / `AuthService.register()`, so there
   is one single place that defines what a `users` document looks like
   and how a role is validated.

8. **Removed 6 completely dead files** (not imported by anything, in
   this or the earlier upload):
   `auth_controller.dart`, `donor_controller.dart`,
   `notification_controller.dart`, `profile_controller.dart`,
   `request_controller.dart` (four of these were literally empty
   files), and `firebase_service.dart` — all fully superseded by the
   `*_service.dart` files, which are the ones actually used throughout
   the app.

## New: `firestore.rules`

There was no security rules file anywhere in the project, meaning the
database is very likely still running on Firebase's default rules —
either wide open to anyone, or fully locked once the test-mode window
expires. Added a rules file matching exactly how the app's services
use each collection (`users`, `requests`, `notifications`,
`admin_stats`), with role-based access so:
- Any signed-in user can search/browse donors and read requests they're
  involved in.
- Only the owner of a `users`/`requests` doc (or an admin) can modify it.
- Notifications are readable by their target user or, for broadcasts, by
  everyone — but the shared `readBy` field can only be touched, not
  other fields tampered with.
- Only admins can delete users/requests/notifications.

**Deploy it:** `firebase deploy --only firestore:rules`

## Manual step required (not something code can automate)

**Making yourself an admin:** registration always creates
`role: 'user'`. To get an admin account, sign up normally, then in the
Firebase Console → Firestore → `users/{your-uid}`, manually change
`role` to `"admin"`. This is intentional — a real app should never let
someone self-promote to admin from the client.

## Not touched (already solid)

`splash.dart`, `dashboard.dart`, `emergency_request.dart` (aside from
the broadcast hook), `find_donor.dart`, `my_request.dart`, all model
files, and `donor_service.dart` / `hospital_service.dart` /
`location_service.dart` / `request_database.dart` were already well
structured with proper error handling, loading/empty states, and
consistent `donorType`/status value handling — no changes needed.

---

# Round 2 — New Features

See `PUBSPEC_ADDITIONS.md` for the exact packages + native setup steps
these require (Google/Apple sign-in and push both need platform config
I can't do blind, without your actual `pubspec.yaml`/Xcode project).

## 1. Push Notifications (FCM)

- New `lib/services/push_notification_service.dart` — requests
  permission, subscribes every device to the `all_users` topic, and
  saves the device's FCM token onto `users/{uid}.fcmToken`.
- `main.dart` now registers a background message handler so pushes
  are received even when the app is closed.
- Called from `dashboard.dart` and `admin_dashboard.dart` on load
  (i.e. once signed in), and the token is cleared on logout.
- New `functions/index.js` — a Cloud Function that fires whenever a
  `notifications` document is created (which already happens for
  broadcasts and personal alerts) and turns it into a real device
  push: to the `all_users` topic for broadcasts, or directly to a
  user's saved token for personal notifications.
- **Requires deploying Cloud Functions** (Blaze plan) — see
  `PUBSPEC_ADDITIONS.md`. Everything else in the app works fine
  without deploying this; only the "push while app is closed" bit
  needs it.

## 2. Google & Apple Sign-In

- `auth_service.dart` now has `signInWithGoogle()` and
  `signInWithApple()`, both routed through a shared
  `_ensureUserDocAndGetRole()` helper so a first-time social sign-in
  creates the exact same `users` document shape as email/password
  registration (role `'user'`, donorType `'None'`, etc.).
- Apple sign-in uses a hashed nonce (Apple's recommended flow) for
  replay protection.
- `login.dart`'s Google/Apple buttons (previously removed as fake
  placeholders) are back and now actually work, with a shared loading
  state and error handling.
- **Needs native setup** (SHA-1 fingerprint, Info.plist URL scheme,
  Xcode capability, enabling providers in Firebase Console) — this
  can't be done from Dart code alone. Full checklist in
  `PUBSPEC_ADDITIONS.md`.

## 3. Donor Availability Toggle

- `UserModel` / `DonorModel` gained `isAvailable` (defaults to `true`).
- My Profile → Donor Information card now shows an **"Available to
  Donate"** switch (only visible once a donor type is set) so a donor
  can temporarily hide from search/map — e.g. sick, traveling, already
  donated recently — without losing their saved blood group/donor type.
- `DonorService.streamDonors()` now filters out `isAvailable == false`
  donors, applied client-side (no new Firestore composite index
  needed).

## 5. Request Expiry

- `RequestModel` gained `isStale` / `displayStatus` — a request that's
  been unfulfilled for **7+ days** now displays as `'Expired'`
  everywhere (My Requests Active/Past split, status badges, Admin
  Dashboard table + stats) **without needing a paid Cloud Function** —
  it's computed client-side from `createdAt`, so it works immediately
  with zero extra setup or billing.
- Admin can still manually persist `'Expired'` as the real stored
  status via the existing status picker (now includes it as an option).
- Optional `functions/index.js` also ships a **scheduled** function
  (`expireStaleRequests`, runs daily) that persists this to Firestore
  automatically — only useful if something *outside* the app queries
  `requests` directly and needs the stored status pre-expired. Skip
  deploying it if you don't need that; the in-app behavior already
  works without it.

## 6. Donor Certificate Verification

- `UserModel` gained `certificateStatus`: `'none' | 'pending' |
  'verified' | 'rejected'`.
- My Profile: uploading a certificate now sets it to `'pending'` and
  shows the real status (Pending / Verified ✓ / Rejected) instead of
  just "uploaded".
- Admin Dashboard: new **"Certificate Verification"** section (only
  appears when there's something to review) listing every donor with
  a pending certificate, with a tap-to-enlarge preview and
  Approve/Reject buttons. Approving/rejecting updates
  `certificateStatus` and sends the donor a real notification (through
  the existing `NotificationService` — which now also pushes to their
  device, see #1) telling them the result.

## Security rules tightened

`firestore.rules` updated so a user can't escalate their own privileges
by writing `role: 'admin'` directly, or self-approve their own
certificate by writing `certificateStatus: 'verified'` — both fields
can now only be changed by an admin. Similarly, a user can now only
change the `status` field on their own request documents (e.g. marking
fulfilled), not silently rewrite other fields like `urgency` or
`hospital` after creation.

