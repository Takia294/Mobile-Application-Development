import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// ============================================================
/// STORAGE SERVICE
/// Single place for Firebase Storage uploads (profile photos,
/// donor certificates). Used by MyProfileScreen.
/// ============================================================
class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to [path] and returns its public download URL,
  /// or null if the upload failed.
  static Future<String?> uploadFile({
    required File file,
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (_) {
      // Non-critical — file may already be gone.
    }
  }
}
