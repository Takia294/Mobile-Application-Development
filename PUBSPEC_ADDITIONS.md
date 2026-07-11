# Add these to your `pubspec.yaml`

I don't have your actual `pubspec.yaml` (it wasn't shared), so rather
than guess and risk overwriting something, add these `dependencies`
entries yourself — they're the only new packages the new features need
(everything else, like `flutter_map`, `geolocator`, `dropdown_search`,
etc. you already had):

```yaml
dependencies:
  firebase_messaging: ^15.1.3   # push notifications
  google_sign_in: ^6.2.1        # Google login
  sign_in_with_apple: ^6.1.3    # Apple login
  crypto: ^3.0.5                # Apple sign-in nonce hashing
```

Then run:
```
flutter pub get
```

(Version numbers above are current as of writing — `flutter pub outdated`
will tell you if newer compatible versions exist by the time you add
them.)

## Native setup required (can't be done from code alone)

### Push Notifications (Android)
Nothing extra needed beyond adding the dependency — `firebase_messaging`
auto-configures from your existing `google-services.json`.

### Push Notifications (iOS)
1. In Xcode, enable **Push Notifications** and **Background Modes →
   Remote notifications** capabilities for the Runner target.
2. Upload an APNs key/certificate in Firebase Console → Project
   Settings → Cloud Messaging.

### Google Sign-In
1. Firebase Console → Authentication → Sign-in method → enable **Google**.
2. **Android**: add your app's SHA-1 (and SHA-256 for release builds)
   fingerprint in Firebase Console → Project Settings → Your app, then
   re-download `google-services.json` and replace the old one.
3. **iOS**: add the `REVERSED_CLIENT_ID` (from `GoogleService-Info.plist`)
   as a URL scheme in `ios/Runner/Info.plist`.

### Apple Sign-In
1. Firebase Console → Authentication → Sign-in method → enable **Apple**.
2. In Xcode, enable the **Sign In with Apple** capability for the Runner
   target (requires an active Apple Developer account).
3. Apple Sign-In only works on real/simulated iOS — the button will
   throw on Android, which is expected; you may want to hide the Apple
   button on Android with `if (!kIsWeb && Platform.isIOS)` if you'd
   rather not show it there at all.

### Cloud Functions (push notification sender + expiry scheduler)
Requires the **Blaze (pay-as-you-go)** plan — Cloud Functions don't run
on the free Spark plan (Firestore/Auth/Storage stay free either way).

```
cd functions
npm install
firebase deploy --only functions
```
