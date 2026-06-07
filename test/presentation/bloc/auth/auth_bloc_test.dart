import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/usecases/check_user_profile.dart';
import 'package:lung_care_mobile/src/domain/usecases/confirm_password_reset.dart';
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
import 'package:lung_care_mobile/src/presentation/bloc/auth/auth_bloc.dart';

import '../../../mocks/mock_auth_repository.dart';

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockRepository;
  late ObserveAuthState observeAuthState;
  late SignInWithEmail signInWithEmail;
  late CreateUserWithEmail createUserWithEmail;
  late SendPasswordReset sendPasswordReset;
  late RequestPasswordResetOtp requestPasswordResetOtp;
  late VerifyPasswordResetOtp verifyPasswordResetOtp;
  late ResendPasswordResetOtp resendPasswordResetOtp;
  late ConfirmPasswordReset confirmPasswordReset;
  late SignOut signOut;
  late SignInWithGoogle signInWithGoogle;
  late CheckUserProfile checkUserProfile;
  late SaveUserProfile saveUserProfile;

  setUpAll(() {
    registerFallbackValue(MockUser());
    registerFallbackValue(MockUserCredential());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    observeAuthState = ObserveAuthState(repository: mockRepository);
    signInWithEmail = SignInWithEmail(repository: mockRepository);
    createUserWithEmail = CreateUserWithEmail(repository: mockRepository);
    sendPasswordReset = SendPasswordReset(repository: mockRepository);
    requestPasswordResetOtp = RequestPasswordResetOtp(
      repository: mockRepository,
    );
    verifyPasswordResetOtp = VerifyPasswordResetOtp(repository: mockRepository);
    resendPasswordResetOtp = ResendPasswordResetOtp(repository: mockRepository);
    confirmPasswordReset = ConfirmPasswordReset(repository: mockRepository);
    signOut = SignOut(repository: mockRepository);
    signInWithGoogle = SignInWithGoogle(repository: mockRepository);
    checkUserProfile = CheckUserProfile(repository: mockRepository);
    saveUserProfile = SaveUserProfile(repository: mockRepository);

    authBloc = AuthBloc(
      observeAuthState: observeAuthState,
      signInWithEmail: signInWithEmail,
      createUserWithEmail: createUserWithEmail,
      sendPasswordReset: sendPasswordReset,
      requestPasswordResetOtp: requestPasswordResetOtp,
      verifyPasswordResetOtp: verifyPasswordResetOtp,
      resendPasswordResetOtp: resendPasswordResetOtp,
      confirmPasswordReset: confirmPasswordReset,
      signOut: signOut,
      signInWithGoogle: signInWithGoogle,
      checkUserProfile: checkUserProfile,
      saveUserProfile: saveUserProfile,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    group('AuthSignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when sign in succeeds and profile exists',
        build: () {
          when(
            () => mockRepository.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => mockUserCredential);
          when(() => mockUserCredential.user).thenReturn(mockUser);
          when(() => mockUser.uid).thenReturn('user-123');
          when(
            () => mockRepository.checkUserProfileExists(any()),
          ).thenAnswer((_) async => true);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthSignInRequested(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthProfileIncomplete] when sign in succeeds but profile missing',
        build: () {
          when(
            () => mockRepository.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => mockUserCredential);
          when(() => mockUserCredential.user).thenReturn(mockUser);
          when(() => mockUser.uid).thenReturn('user-123');
          when(
            () => mockRepository.checkUserProfileExists(any()),
          ).thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthSignInRequested(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [isA<AuthLoading>(), isA<AuthProfileIncomplete>()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails with invalid credentials',
        build: () {
          when(
            () => mockRepository.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'invalid-credential',
              message: 'Invalid credentials',
            ),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthSignInRequested(
            email: 'test@example.com',
            password: 'wrong-password',
          ),
        ),
        expect: () => [
          isA<AuthLoading>(),
          predicate<AuthError>(
            (state) =>
                state.message ==
                'Email atau password yang Anda masukkan salah.',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails with network error',
        build: () {
          when(
            () => mockRepository.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(Exception('Network error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthSignInRequested(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          isA<AuthLoading>(),
          predicate<AuthError>(
            (state) =>
                state.message == 'Login gagal. Periksa koneksi internet Anda.',
          ),
        ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthLoggedOut] when sign out succeeds',
        build: () {
          when(() => mockRepository.signOut()).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthSignOutRequested()),
        expect: () => [isA<AuthLoading>(), isA<AuthLoggedOut>()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign out fails',
        build: () {
          when(() => mockRepository.signOut()).thenThrow(
            FirebaseAuthException(
              code: 'sign-out-failed',
              message: 'Sign out failed',
            ),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthSignOutRequested()),
        expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      );
    });

    group('AuthPasswordResetOtpRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthPasswordResetOtpSent] when request succeeds',
        build: () {
          final result = createMockPasswordResetRequestResult();
          when(
            () => mockRepository.requestPasswordResetOtp(
              identifier: any(named: 'identifier'),
            ),
          ).thenAnswer((_) async => result);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthPasswordResetOtpRequested(identifier: 'test@example.com'),
        ),
        expect: () => [isA<AuthLoading>(), isA<AuthPasswordResetOtpSent>()],
      );
    });

    group('AuthPasswordResetOtpVerified', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthPasswordResetOtpVerificationSuccess] when verification succeeds',
        build: () {
          final result = createMockPasswordResetVerificationResult();
          when(
            () => mockRepository.verifyPasswordResetOtp(
              requestId: any(named: 'requestId'),
              code: any(named: 'code'),
            ),
          ).thenAnswer((_) async => result);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthPasswordResetOtpVerified(requestId: 'request-1', code: '123456'),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthPasswordResetOtpVerificationSuccess>(),
        ],
      );
    });

    group('AuthPasswordResetConfirmed', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthPasswordResetCompleted] when password reset succeeds',
        build: () {
          when(
            () => mockRepository.confirmPasswordReset(
              resetToken: any(named: 'resetToken'),
              newPassword: any(named: 'newPassword'),
            ),
          ).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthPasswordResetConfirmed(
            resetToken: 'reset-token',
            newPassword: 'newPassword123',
          ),
        ),
        expect: () => [isA<AuthLoading>(), isA<AuthPasswordResetCompleted>()],
      );
    });

    group('AuthPasswordResetRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when password reset email sent',
        build: () {
          when(
            () => mockRepository.sendPasswordResetEmail(
              email: any(named: 'email'),
            ),
          ).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(AuthPasswordResetRequested(email: 'test@example.com')),
        expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
      );
    });
  });
}
