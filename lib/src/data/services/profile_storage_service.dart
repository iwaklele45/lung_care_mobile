import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Handles uploading & deleting profile pictures in Firebase Storage.
///
/// Images are stored at `profile_pictures/{uid}.jpg` and overwritten on
/// re-upload so there's only ever one image per user.
class ProfileStorageService {
  ProfileStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Uploads [imageFile] and returns the public download URL.
  ///
  /// Overwrites any previous profile picture for this [uid].
  Future<String> upload({required String uid, required File imageFile}) async {
    final ref = _storage.ref().child('profile_pictures/$uid.jpg');
    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }

  /// Deletes the profile picture for [uid] (if it exists).
  ///
  /// Swallows "object not found" errors so this is safe to call even
  /// when the user never had a picture.
  Future<void> delete(String uid) async {
    try {
      await _storage.ref().child('profile_pictures/$uid.jpg').delete();
    } on FirebaseException catch (e) {
      // code 'object-not-found' → nothing to delete → fine.
      if (e.code != 'object-not-found') rethrow;
    }
  }
}
