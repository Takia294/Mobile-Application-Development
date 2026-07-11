import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/user_model.dart';

/// ============================================================
/// AUTH SERVICE
/// Central place for register/login/logout + role lookup, used by
/// LoginScreen and RegistrationScreen. Keeps the Firestore `users`
/// document shape (see UserModel) consistent in one place instead
/// of being duplicated inline in each screen.
/// ============================================================
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;

  /// Registers a new donor account and creates their Firestore
  /// profile document. Returns the created [UserModel].
  static Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String house,
    required String road,
    required String area,
    required String city,
    required String gender,
    required String dob,
    double? latitude,
    double? longitude,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final user = UserModel(
      uid: uid,
      fullName: fullName,
      email: email,
      phone: phone,
      house: house,
      road: road,
      area: area,
      city: city,
      gender: gender,
      dob: dob,
      bloodGroup: '',
      donorType: 'None',
      role: 'user',
      latitude: latitude,
      longitude: longitude,
      locationUpdatedAt: latitude != null ? Timestamp.now() : null,
      createdAt: Timestamp.now(),
    );

    await _db.collection('users').doc(uid).set(user.toMap());
    return user;
  }

  /// Signs in and returns the user's role ('user' | 'admin').
  /// Throws if the Firestore profile document is missing.
  static Future<String> loginAndGetRole({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc =
        await _db.collection('users').doc(credential.user!.uid).get();

    if (!doc.exists) {
      await _auth.signOut();
      throw AuthServiceException('User data not found. Contact support.');
    }

    final role = doc.data()?['role'] ?? '';
    if (role != 'admin' && role != 'user') {
      await _auth.signOut();
      throw AuthServiceException('Access denied. Unknown role.');
    }
    return role;
  }

  static Future<void> logout() async => _auth.signOut();

  /// ── GOOGLE SIGN-IN ──
  /// Returns the signed-in user's role, creating a Firestore profile
  /// on first sign-in (same document shape as email/password
  /// registration, just without a phone/address/DOB yet — the user
  /// can fill those in later from My Profile).
  static Future<String> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw AuthServiceException('Google sign-in was cancelled.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;

    return _ensureUserDocAndGetRole(
      uid: user.uid,
      email: user.email ?? googleUser.email,
      fallbackName: user.displayName ?? googleUser.displayName ?? '',
    );
  }

  /// ── APPLE SIGN-IN ──
  /// Uses a hashed nonce (Apple's recommended flow) to prevent replay
  /// attacks. Apple only shares the user's name on their very first
  /// sign-in ever, so [fallbackName] may be empty on repeat sign-ins —
  /// that's expected and fine, the Firestore doc already has the name
  /// saved from the first time.
  static Future<String> signInWithApple() async {
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);
    final user = userCredential.user!;

    final fallbackName = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].where((s) => s != null && s.trim().isNotEmpty).join(' ');

    return _ensureUserDocAndGetRole(
      uid: user.uid,
      email: user.email ?? appleCredential.email ?? '',
      fallbackName: fallbackName,
    );
  }

  /// Creates a minimal `users` doc on first social sign-in (matching
  /// the same shape/defaults as [register]), or just reads the role
  /// back if the doc already exists. Shared by Google + Apple.
  static Future<String> _ensureUserDocAndGetRole({
    required String uid,
    required String email,
    required String fallbackName,
  }) async {
    final docRef = _db.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      final user = UserModel(
        uid: uid,
        fullName: fallbackName,
        email: email,
        phone: '',
        bloodGroup: '',
        donorType: 'None',
        role: 'user',
        createdAt: Timestamp.now(),
      );
      await docRef.set(user.toMap());
      return 'user';
    }

    final role = doc.data()?['role'] ?? '';
    if (role != 'admin' && role != 'user') {
      await _auth.signOut();
      throw AuthServiceException('Access denied. Unknown role.');
    }
    return role;
  }

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String _sha256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  static Future<UserModel?> getCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromDoc(doc);
  }
}

class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);
  @override
  String toString() => message;
}
