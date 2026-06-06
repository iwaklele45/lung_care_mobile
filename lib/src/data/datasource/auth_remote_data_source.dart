import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lung_care_mobile/src/domain/entities/password_reset_result.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final GoogleSignIn _googleSignIn;

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

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Login Google dibatalkan.',
      );
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<bool> checkUserProfileExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String phoneNumber,
    required String address,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name.trim(),
      'phoneNumber': phoneNumber.trim(),
      'address': address.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
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

  Future<PasswordResetRequestResult> requestPasswordResetOtp({
    required String identifier,
  }) async {
    final response = await _functions
        .httpsCallable('requestPasswordReset')
        .call({'identifier': identifier});
    return _passwordResetRequestResultFrom(response.data);
  }

  Future<PasswordResetVerificationResult> verifyPasswordResetOtp({
    required String requestId,
    required String code,
  }) async {
    final response = await _functions
        .httpsCallable('verifyPasswordResetCode')
        .call({'requestId': requestId, 'code': code});
    final data = Map<String, dynamic>.from(response.data as Map);
    return PasswordResetVerificationResult(
      resetToken: data['resetToken'] as String,
    );
  }

  Future<PasswordResetRequestResult> resendPasswordResetOtp({
    required String requestId,
  }) async {
    final response = await _functions
        .httpsCallable('resendPasswordResetCode')
        .call({'requestId': requestId});
    return _passwordResetRequestResultFrom(response.data);
  }

  Future<void> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  }) async {
    await _functions.httpsCallable('confirmPasswordReset').call({
      'resetToken': resetToken,
      'newPassword': newPassword,
    });
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // No Google session to disconnect — safe to ignore
    }
    await _firebaseAuth.signOut();
  }

  PasswordResetRequestResult _passwordResetRequestResultFrom(Object? value) {
    final data = Map<String, dynamic>.from(value as Map);
    final resendAvailableAt = data['resendAvailableAt'];
    return PasswordResetRequestResult(
      requestId: data['requestId'] as String,
      maskedDestination: data['maskedDestination'] as String,
      channel: data['channel'] as String,
      demoCode: data['demoCode'] as String?,
      resendAvailableAt: DateTime.fromMillisecondsSinceEpoch(
        resendAvailableAt is int
            ? resendAvailableAt
            : (resendAvailableAt as num).toInt(),
      ),
    );
  }
}
