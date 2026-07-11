import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final FirebaseStorage storage =
      FirebaseStorage.instance;

  /// CURRENT USER
  User? get currentUser =>
      auth.currentUser;

  /// GET USER DATA
  Future<DocumentSnapshot>
      getUserData() async {

    return await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();
  }

  /// UPDATE USER
  Future<void> updateUserData(
    Map<String, dynamic> data,
  ) async {

    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .update(data);
  }

  /// UPLOAD IMAGE
  Future<String> uploadImage({
    required File file,
    required String path,
  }) async {

    final ref = storage.ref().child(
      '$path/${currentUser!.uid}.jpg',
    );

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  /// LOGOUT
  Future<void> logout() async {
    await auth.signOut();
  }
}