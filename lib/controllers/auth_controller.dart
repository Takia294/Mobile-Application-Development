import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController {

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// REGISTER
  Future<String?> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {

    try {

      /// CREATE USER
      UserCredential userCredential =
          await _auth
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      /// SAVE FIRESTORE
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({

        'uid': userCredential.user!.uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'createdAt':
            Timestamp.now(),
      });

      return null;

    } on FirebaseAuthException catch (e) {

      return e.message;
    }
  }

  /// LOGIN
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {

    try {

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;

    } on FirebaseAuthException catch (e) {

      return e.message;
    }
  }

  /// CURRENT USER
  User? get currentUser =>
      _auth.currentUser;

  /// LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}