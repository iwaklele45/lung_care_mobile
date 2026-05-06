import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< HEAD
=======
import 'package:lung_care_mobile/features/auth/domain/usecases/create_user_with_email.dart';
import 'package:lung_care_mobile/features/auth/domain/usecases/observe_auth_state.dart';
import 'package:lung_care_mobile/features/auth/domain/usecases/send_password_reset.dart';
import 'package:lung_care_mobile/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:lung_care_mobile/features/auth/domain/usecases/sign_out.dart';
>>>>>>> feature/login
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required ObserveAuthState observeAuthState,
    required SignInWithEmail signInWithEmail,
    required CreateUserWithEmail createUserWithEmail,
    required SendPasswordReset sendPasswordReset,
    required SignOut signOut,
  })  : _observeAuthState = observeAuthState,
        _signInWithEmail = signInWithEmail,
        _createUserWithEmail = createUserWithEmail,
        _sendPasswordReset = sendPasswordReset,
        _signOut = signOut,
        super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final ObserveAuthState _observeAuthState;
  final SignInWithEmail _signInWithEmail;
  final CreateUserWithEmail _createUserWithEmail;
  final SendPasswordReset _sendPasswordReset;
  final SignOut _signOut;
  StreamSubscription<User?>? _authSubscription;

  void _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) {
    _authSubscription?.cancel();
    _authSubscription = _observeAuthState().listen(
      (user) => add(AuthUserChanged(user)),
      onError: (error) => add(AuthUserChanged(null)),
    );
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
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
<<<<<<< HEAD
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(AuthUnauthenticated());
      } else {
        emit(AuthAuthenticated());
      }
    } catch (error) {
      emit(AuthError(error.toString()));
    }
=======
    emit(AuthLoading());
    try {
      await _signInWithEmail(
        email: event.email,
        password: event.password,
      );
    } on FirebaseAuthException catch (error) {
      emit(AuthError(error.message ?? 'Login gagal.'));
    } catch (_) {
      emit(AuthError('Login gagal.'));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _createUserWithEmail(
        email: event.email,
        password: event.password,
      );
    } on FirebaseAuthException catch (error) {
      emit(AuthError(error.message ?? 'Pendaftaran gagal.'));
    } catch (_) {
      emit(AuthError('Pendaftaran gagal.'));
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
>>>>>>> feature/login
  }
}
