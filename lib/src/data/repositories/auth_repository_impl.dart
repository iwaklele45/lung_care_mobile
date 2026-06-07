import 'package:firebase_auth/firebase_auth.dart';
import 'package:lung_care_mobile/src/data/datasource/auth_remote_data_source.dart';
import 'package:lung_care_mobile/src/domain/entities/password_reset_result.dart';
import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<User?> authStateChanges() => _remoteDataSource.authStateChanges();

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required String address,
    String? profilePicturePath,
  }) {
    return _remoteDataSource.createUserWithEmailAndPassword(
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
      address: address,
      profilePicturePath: profilePicturePath,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _remoteDataSource.sendPasswordResetEmail(email: email);
  }

  @override
  Future<PasswordResetRequestResult> requestPasswordResetOtp({
    required String identifier,
  }) {
    return _remoteDataSource.requestPasswordResetOtp(identifier: identifier);
  }

  @override
  Future<PasswordResetVerificationResult> verifyPasswordResetOtp({
    required String requestId,
    required String code,
  }) {
    return _remoteDataSource.verifyPasswordResetOtp(
      requestId: requestId,
      code: code,
    );
  }

  @override
  Future<PasswordResetRequestResult> resendPasswordResetOtp({
    required String requestId,
  }) {
    return _remoteDataSource.resendPasswordResetOtp(requestId: requestId);
  }

  @override
  Future<void> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  }) {
    return _remoteDataSource.confirmPasswordReset(
      resetToken: resetToken,
      newPassword: newPassword,
    );
  }

  @override
  Future<UserCredential> signInWithGoogle() {
    return _remoteDataSource.signInWithGoogle();
  }

  @override
  Future<bool> checkUserProfileExists(String uid) {
    return _remoteDataSource.checkUserProfileExists(uid);
  }

  @override
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String phoneNumber,
    required String address,
    required String email,
    String? profilePicturePath,
  }) {
    return _remoteDataSource.saveUserProfile(
      uid: uid,
      name: name,
      phoneNumber: phoneNumber,
      address: address,
      email: email,
      profilePicturePath: profilePicturePath,
    );
  }

  @override
  Future<void> signOut() => _remoteDataSource.signOut();
}
