import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lung_care_mobile/src/domain/entities/password_reset_result.dart';
import 'package:lung_care_mobile/src/domain/usecases/confirm_password_reset.dart';
import 'package:lung_care_mobile/src/domain/usecases/check_user_profile.dart';
import 'package:lung_care_mobile/src/domain/usecases/create_user_with_email.dart';
import 'package:lung_care_mobile/src/domain/usecases/observe_auth_state.dart';
import 'package:lung_care_mobile/src/domain/usecases/request_password_reset_otp.dart';
import 'package:lung_care_mobile/src/domain/usecases/resend_password_reset_otp.dart';
import 'package:lung_care_mobile/src/domain/usecases/save_user_profile.dart';
import 'package:lung_care_mobile/src/domain/usecases/send_password_reset.dart';
import 'package:lung_care_mobile/src/domain/usecases/sign_in_with_email.dart';
import 'package:lung_care_mobile/src/domain/usecases/sign_in_with_google.dart';
import 'package:lung_care_mobile/src/domain/usecases/sign_out.dart';
import 'package:lung_care_mobile/src/domain/usecases/verify_password_reset_otp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required ObserveAuthState observeAuthState,
    required SignInWithEmail signInWithEmail,
    required CreateUserWithEmail createUserWithEmail,
    required SendPasswordReset sendPasswordReset,
    required RequestPasswordResetOtp requestPasswordResetOtp,
    required VerifyPasswordResetOtp verifyPasswordResetOtp,
    required ResendPasswordResetOtp resendPasswordResetOtp,
    required ConfirmPasswordReset confirmPasswordReset,
    required SignOut signOut,
    required SignInWithGoogle signInWithGoogle,
    required CheckUserProfile checkUserProfile,
    required SaveUserProfile saveUserProfile,
  }) : _observeAuthState = observeAuthState,
       _signInWithEmail = signInWithEmail,
       _createUserWithEmail = createUserWithEmail,
       _sendPasswordReset = sendPasswordReset,
       _requestPasswordResetOtp = requestPasswordResetOtp,
       _verifyPasswordResetOtp = verifyPasswordResetOtp,
       _resendPasswordResetOtp = resendPasswordResetOtp,
       _confirmPasswordReset = confirmPasswordReset,
       _signOut = signOut,
       _signInWithGoogle = signInWithGoogle,
       _checkUserProfile = checkUserProfile,
       _saveUserProfile = saveUserProfile,
       super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthPasswordResetOtpRequested>(_onPasswordResetOtpRequested);
    on<AuthPasswordResetOtpVerified>(_onPasswordResetOtpVerified);
    on<AuthPasswordResetOtpResent>(_onPasswordResetOtpResent);
    on<AuthPasswordResetConfirmed>(_onPasswordResetConfirmed);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSaveProfileRequested>(_onSaveProfileRequested);
  }

  final ObserveAuthState _observeAuthState;
  final SignInWithEmail _signInWithEmail;
  final CreateUserWithEmail _createUserWithEmail;
  final SendPasswordReset _sendPasswordReset;
  final RequestPasswordResetOtp _requestPasswordResetOtp;
  final VerifyPasswordResetOtp _verifyPasswordResetOtp;
  final ResendPasswordResetOtp _resendPasswordResetOtp;
  final ConfirmPasswordReset _confirmPasswordReset;
  final SignOut _signOut;
  final SignInWithGoogle _signInWithGoogle;
  final CheckUserProfile _checkUserProfile;
  final SaveUserProfile _saveUserProfile;
  StreamSubscription<User?>? _authSubscription;
  bool _isRegistering = false;
  bool _isSigningIn = false;
  bool _isGoogleSigningIn = false;
  bool _isSigningOut = false;

  void _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) {
    _authSubscription?.cancel();
    _authSubscription = _observeAuthState().listen(
      (user) => add(AuthUserChanged(user)),
      onError: (error) => add(AuthUserChanged(null)),
    );
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (_isRegistering || _isSigningIn || _isGoogleSigningIn || _isSigningOut) {
      return;
    }
    final user = event.user;
    if (user is User) {
      // Check if the user has completed their profile in Firestore
      try {
        final profileExists = await _checkUserProfile(uid: user.uid);
        if (profileExists) {
          emit(AuthAuthenticated());
        } else {
          emit(AuthProfileIncomplete());
        }
      } catch (_) {
        // If profile check fails, assume incomplete to be safe
        emit(AuthProfileIncomplete());
      }
      return;
    }
    emit(AuthUnauthenticated());
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    _isSigningIn = true;
    try {
      final userCredential = await _signInWithEmail(
        email: event.email,
        password: event.password,
      );
      final user = userCredential.user;
      if (user == null) {
        emit(AuthError('Login gagal.'));
        return;
      }

      final profileExists = await _checkUserProfile(uid: user.uid);
      if (profileExists) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthProfileIncomplete());
      }
    } on FirebaseAuthException catch (error) {
      // Menangkap kode error spesifik dari Firebase
      switch (error.code) {
        case 'invalid-credential':
        case 'user-not-found': // Kode legacy (untuk kompatibilitas)
        case 'wrong-password': // Kode legacy (untuk kompatibilitas)
          emit(AuthError('Email atau password yang Anda masukkan salah.'));
          break;
        case 'invalid-email':
          emit(AuthError('Format email tidak valid.'));
          break;
        case 'user-disabled':
          emit(AuthError('Akun ini telah dinonaktifkan oleh Admin.'));
          break;
        case 'too-many-requests':
          emit(
            AuthError(
              'Terlalu banyak percobaan. Silakan coba lagi beberapa saat.',
            ),
          );
          break;
        default:
          // Fallback jika terjadi error lain (seperti server down)
          emit(AuthError(error.message ?? 'Login gagal. Silakan coba lagi.'));
      }
    } catch (_) {
      // Catch umum (biasanya karena tidak ada koneksi internet sama sekali)
      emit(AuthError('Login gagal. Periksa koneksi internet Anda.'));
    } finally {
      _isSigningIn = false;
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    _isGoogleSigningIn = true;
    try {
      final userCredential = await _signInWithGoogle();
      final user = userCredential.user;
      if (user == null) {
        emit(AuthError('Login Google gagal.'));
        return;
      }

      final profileExists = await _checkUserProfile(uid: user.uid);
      if (profileExists) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthProfileIncomplete());
      }
    } on FirebaseAuthException catch (error) {
      emit(AuthError(error.message ?? 'Login Google gagal.'));
    } catch (_) {
      emit(AuthError('Login Google gagal.'));
    } finally {
      _isGoogleSigningIn = false;
    }
  }

  Future<void> _onSaveProfileRequested(
    AuthSaveProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = _observeAuthState.currentUser;
      if (user == null) {
        emit(AuthError('Sesi login tidak ditemukan. Silakan login ulang.'));
        return;
      }

      await user.updateDisplayName(event.name.trim());
      await user.reload();

      await _saveUserProfile(
        uid: user.uid,
        name: event.name,
        phoneNumber: event.phoneNumber,
        address: event.address,
        email: user.email ?? '',
        profilePicturePath: event.profilePicturePath,
      );

      emit(AuthProfileSaved());
    } on FirebaseException catch (error) {
      emit(AuthError(error.message ?? 'Gagal menyimpan profil.'));
    } catch (_) {
      emit(AuthError('Gagal menyimpan profil.'));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    _isRegistering = true;
    try {
      await _createUserWithEmail(
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
        email: event.email,
        password: event.password,
        address: event.address,
        profilePicturePath: event.profilePicturePath,
      );
      await _signOut();
      emit(AuthRegistrationSuccess());
    } on FirebaseAuthException catch (error) {
      emit(AuthError(error.message ?? 'Pendaftaran gagal.'));
    } on FirebaseException catch (error) {
      emit(AuthError(error.message ?? 'Pendaftaran gagal.'));
    } catch (_) {
      emit(AuthError('Pendaftaran gagal.'));
    } finally {
      _isRegistering = false;
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _sendPasswordReset(email: event.email);
      emit(AuthUnauthenticated());
    } on FirebaseAuthException catch (error) {
      emit(AuthError(error.message ?? 'Gagal mengirim email reset.'));
    } catch (_) {
      emit(AuthError('Gagal mengirim email reset.'));
    }
  }

  Future<void> _onPasswordResetOtpRequested(
    AuthPasswordResetOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _requestPasswordResetOtp(
        identifier: event.identifier,
      );
      emit(AuthPasswordResetOtpSent(result));
    } on FirebaseFunctionsException catch (error) {
      emit(AuthError(_passwordResetMessage(error)));
    } catch (_) {
      emit(AuthError('Gagal mengirim kode reset.'));
    }
  }

  Future<void> _onPasswordResetOtpVerified(
    AuthPasswordResetOtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _verifyPasswordResetOtp(
        requestId: event.requestId,
        code: event.code,
      );
      emit(AuthPasswordResetOtpVerificationSuccess(result));
    } on FirebaseFunctionsException catch (error) {
      emit(AuthError(_passwordResetMessage(error)));
    } catch (_) {
      emit(AuthError('Gagal memverifikasi kode.'));
    }
  }

  Future<void> _onPasswordResetOtpResent(
    AuthPasswordResetOtpResent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _resendPasswordResetOtp(requestId: event.requestId);
      emit(AuthPasswordResetOtpSent(result));
    } on FirebaseFunctionsException catch (error) {
      emit(AuthError(_passwordResetMessage(error)));
    } catch (_) {
      emit(AuthError('Gagal mengirim ulang kode.'));
    }
  }

  Future<void> _onPasswordResetConfirmed(
    AuthPasswordResetConfirmed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _confirmPasswordReset(
        resetToken: event.resetToken,
        newPassword: event.newPassword,
      );
      emit(AuthPasswordResetCompleted());
    } on FirebaseFunctionsException catch (error) {
      emit(AuthError(_passwordResetMessage(error)));
    } catch (_) {
      emit(AuthError('Gagal menyimpan password baru.'));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    _isSigningOut = true;
    try {
      await _signOut();
      emit(AuthLoggedOut());
    } on FirebaseAuthException catch (error) {
      emit(AuthError(error.message ?? 'Logout gagal.'));
    } catch (_) {
      emit(AuthError('Logout gagal.'));
    } finally {
      _isSigningOut = false;
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  String _passwordResetMessage(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'invalid-argument':
      case 'permission-denied':
      case 'not-found':
      case 'deadline-exceeded':
      case 'resource-exhausted':
      case 'failed-precondition':
        return error.message ?? 'Permintaan reset password tidak valid.';
      default:
        return error.message ?? 'Reset password gagal. Silakan coba lagi.';
    }
  }
}
