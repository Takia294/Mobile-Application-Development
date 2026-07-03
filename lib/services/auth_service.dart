import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
