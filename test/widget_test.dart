import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lung_care_mobile/src/domain/entities/password_reset_result.dart';
import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';
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
import 'package:lung_care_mobile/src/presentation/pages/auth/forgot_password_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/auth/password_reset_route_data.dart';
import 'package:lung_care_mobile/src/presentation/pages/auth/register_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/auth/reset_password_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/auth/verify_code_page.dart';

void main() {
  testWidgets('register page renders expected sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpAuthPage(const RegisterPage());

    expect(find.text('Daftar Akun Baru'), findsOneWidget);
    expect(find.text('Mulai Perjalanan\nSehat'), findsOneWidget);
    expect(find.text('Buat Akun'), findsOneWidget);
    expect(find.text('Daftar dengan Google'), findsOneWidget);
  });

  testWidgets('forgot password rejects empty identifier', (
    WidgetTester tester,
  ) async {
    await tester.pumpAuthPage(const ForgotPasswordPage());

    await tester.tap(find.text('Kirim Instruksi'));
    await tester.pump();

    expect(find.text('Email atau nomor HP wajib diisi.'), findsOneWidget);
  });

  testWidgets('verify code renders six OTP fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpAuthPage(
      VerifyCodePage(
        data: VerifyCodeRouteData(
          requestId: 'request-1',
          maskedDestination: 'b***@example.com',
          channel: 'email',
          demoCode: '123456',
          resendAvailableAt: DateTime.now().add(const Duration(seconds: 60)),
        ),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(6));
    expect(find.text('Verifikasi'), findsOneWidget);
  });

  testWidgets('reset password rejects mismatched confirmation', (
    WidgetTester tester,
  ) async {
    await tester.pumpAuthPage(
      const ResetPasswordPage(
        data: ResetPasswordRouteData(resetToken: 'reset-token'),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Masukkan kata sandi baru'),
      'password1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ketik ulang kata sandi baru'),
      'password2',
    );
    await tester.tap(find.text('Simpan & Masuk'));
    await tester.pump();

    expect(find.text('Konfirmasi password tidak sama.'), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> pumpAuthPage(Widget page) {
    final repository = _FakeAuthRepository();
    return pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            observeAuthState: ObserveAuthState(repository: repository),
            signInWithEmail: SignInWithEmail(repository: repository),
            createUserWithEmail: CreateUserWithEmail(repository: repository),
            sendPasswordReset: SendPasswordReset(repository: repository),
            requestPasswordResetOtp: RequestPasswordResetOtp(
              repository: repository,
            ),
            verifyPasswordResetOtp: VerifyPasswordResetOtp(
              repository: repository,
            ),
            resendPasswordResetOtp: ResendPasswordResetOtp(
              repository: repository,
            ),
            confirmPasswordReset: ConfirmPasswordReset(repository: repository),
            signOut: SignOut(repository: repository),
            signInWithGoogle: SignInWithGoogle(repository: repository),
            checkUserProfile: CheckUserProfile(repository: repository),
            saveUserProfile: SaveUserProfile(repository: repository),
          ),
          child: page,
        ),
      ),
    );
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  User? get currentUser => null;

  @override
  Stream<User?> authStateChanges() => const Stream<User?>.empty();

  @override
  Future<bool> checkUserProfileExists(String uid) async => true;

  @override
  Future<void> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  }) async {}

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required String address,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PasswordResetRequestResult> requestPasswordResetOtp({
    required String identifier,
  }) async {
    return PasswordResetRequestResult(
      requestId: 'request-1',
      maskedDestination: 'b***@example.com',
      channel: 'email',
      demoCode: '123456',
      resendAvailableAt: DateTime.now().add(const Duration(seconds: 60)),
    );
  }

  @override
  Future<PasswordResetRequestResult> resendPasswordResetOtp({
    required String requestId,
  }) async {
    return PasswordResetRequestResult(
      requestId: requestId,
      maskedDestination: 'b***@example.com',
      channel: 'email',
      demoCode: '654321',
      resendAvailableAt: DateTime.now().add(const Duration(seconds: 60)),
    );
  }

  @override
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String phoneNumber,
    required String address,
    required String email,
  }) async {}

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<PasswordResetVerificationResult> verifyPasswordResetOtp({
    required String requestId,
    required String code,
  }) async {
    return const PasswordResetVerificationResult(resetToken: 'reset-token');
  }
}
