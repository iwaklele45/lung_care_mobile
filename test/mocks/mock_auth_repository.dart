import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/entities/password_reset_result.dart';
import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

final mockUser = MockUser();

final mockUserCredential = MockUserCredential();

PasswordResetRequestResult createMockPasswordResetRequestResult({
  String? requestId,
  String? maskedDestination,
  String? channel,
  String? demoCode,
}) {
  return PasswordResetRequestResult(
    requestId: requestId ?? 'request-1',
    maskedDestination: maskedDestination ?? 'b***@example.com',
    channel: channel ?? 'email',
    demoCode: demoCode ?? '123456',
    resendAvailableAt: DateTime.now().add(const Duration(seconds: 60)),
  );
}

PasswordResetVerificationResult createMockPasswordResetVerificationResult({
  String? resetToken,
}) {
  return PasswordResetVerificationResult(
    resetToken: resetToken ?? 'reset-token',
  );
}
