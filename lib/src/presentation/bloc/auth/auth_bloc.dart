import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lung_care_mobile/src/domain/usecases/check_user_profile.dart';
import 'package:lung_care_mobile/src/domain/usecases/create_user_with_email.dart';
import 'package:lung_care_mobile/src/domain/usecases/observe_auth_state.dart';
import 'package:lung_care_mobile/src/domain/usecases/save_user_profile.dart';
import 'package:lung_care_mobile/src/domain/usecases/send_password_reset.dart';
import 'package:lung_care_mobile/src/domain/usecases/sign_in_with_email.dart';
import 'package:lung_care_mobile/src/domain/usecases/sign_in_with_google.dart';
import 'package:lung_care_mobile/src/domain/usecases/sign_out.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required ObserveAuthState observeAuthState,
    required SignInWithEmail signInWithEmail,
    required CreateUserWithEmail createUserWithEmail,
    required SendPasswordReset sendPasswordReset,
    required SignOut signOut,
    required SignInWithGoogle signInWithGoogle,
    required CheckUserProfile checkUserProfile,
    required SaveUserProfile saveUserProfile,
  }) : _observeAuthState = observeAuthState,
       _signInWithEmail = signInWithEmail,
       _createUserWithEmail = createUserWithEmail,
       _sendPasswordReset = sendPasswordReset,
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
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSaveProfileRequested>(_onSaveProfileRequested);
  }

  final ObserveAuthState _observeAuthState;
  final SignInWithEmail _signInWithEmail;
  final CreateUserWithEmail _createUserWithEmail;
  final SendPasswordReset _sendPasswordReset;
  final SignOut _signOut;
  final SignInWithGoogle _signInWithGoogle;
  final CheckUserProfile _checkUserProfile;
  final SaveUserProfile _saveUserProfile;
  StreamSubscription<User?>? _authSubscription;
  bool _isRegistering = false;
  bool _isGoogleSigningIn = false;

  void _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) {
    _authSubscription?.cancel();
    _authSubscription = _observeAuthState().listen(
      (user) => add(AuthUserChanged(user)),
      onError: (error) => add(AuthUserChanged(null)),
    );
  }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (_isRegistering || _isGoogleSigningIn) return;
    final user = event.user;
    if (user is User) {
      emit(AuthAuthenticated());
      return;
    }
    emit(AuthUnauthenticated());
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _signInWithEmail(email: event.email, password: event.password);
    } on FirebaseAuthException catch (error) {
      emit(AuthError(error.message ?? 'Login gagal.'));
    } catch (_) {
      emit(AuthError('Login gagal.'));
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

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _signOut();
      emit(AuthUnauthenticated());
    } on FirebaseAuthException catch (error) {
      emit(AuthError(error.message ?? 'Logout gagal.'));
    } catch (_) {
      emit(AuthError('Logout gagal.'));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}

