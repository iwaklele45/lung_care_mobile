import 'package:firebase_auth/firebase_auth.dart';
import 'package:lung_care_mobile/src/domain/entities/password_reset_result.dart';

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
  Future<PasswordResetRequestResult> requestPasswordResetOtp({
    required String identifier,
  });
  Future<PasswordResetVerificationResult> verifyPasswordResetOtp({
    required String requestId,
    required String code,
  });
  Future<PasswordResetRequestResult> resendPasswordResetOtp({
    required String requestId,
  });
  Future<void> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  });
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
