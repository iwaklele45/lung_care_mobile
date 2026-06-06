import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();
  User? get currentUser;
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserCredential> createUserWithEmailAndPassword({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required String address,
    String? profilePicturePath,
  });
  Future<void> sendPasswordResetEmail({required String email});
  Future<UserCredential> signInWithGoogle();
  Future<bool> checkUserProfileExists(String uid);
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String phoneNumber,
    required String address,
    required String email,
    String? profilePicturePath,
  });
  Future<void> signOut();
}
