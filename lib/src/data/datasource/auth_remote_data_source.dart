import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required String address,
  }) async {
    final normalizedFullName = fullName.trim();
    final normalizedPhoneNumber = phoneNumber.trim();
    final normalizedAddress = address.trim();
    final normalizedEmail = email.trim();

    if (normalizedFullName.isEmpty ||
        normalizedPhoneNumber.isEmpty ||
        normalizedAddress.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-registration-data',
        message: 'Data pendaftaran belum lengkap.',
      );
    }

    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Akun berhasil dibuat, namun data pengguna tidak ditemukan.',
      );
    }

    try {
      await user.updateDisplayName(normalizedFullName);
      await user.reload();

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': normalizedFullName,
        'phoneNumber': normalizedPhoneNumber,
        'address': normalizedAddress,
        'email': normalizedEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
      try {
        await user.delete();
      } catch (_) {
        // Best-effort rollback. Keeping the original error preserves root cause.
      }
      rethrow;
    }

    return userCredential;
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
