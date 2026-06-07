import 'package:flutter_test/flutter_test.dart';
import 'package:lung_care_mobile/src/domain/entities/password_reset_result.dart';

void main() {
  group('PasswordResetRequestResult', () {
    test('has correct properties', () {
      final now = DateTime.now();
      final result = PasswordResetRequestResult(
        requestId: 'req-123',
        maskedDestination: 'b***@example.com',
        channel: 'email',
        resendAvailableAt: now.add(const Duration(seconds: 60)),
        demoCode: '123456',
      );

      expect(result.requestId, 'req-123');
      expect(result.maskedDestination, 'b***@example.com');
      expect(result.channel, 'email');
      expect(result.resendAvailableAt, now.add(const Duration(seconds: 60)));
      expect(result.demoCode, '123456');
    });

    test('can be created without demoCode', () {
      final result = PasswordResetRequestResult(
        requestId: 'req-123',
        maskedDestination: 'b***@example.com',
        channel: 'email',
        resendAvailableAt: DateTime.now(),
      );

      expect(result.demoCode, isNull);
    });
  });

  group('PasswordResetVerificationResult', () {
    test('has correct properties', () {
      const result = PasswordResetVerificationResult(
        resetToken: 'token-abc-123',
      );

      expect(result.resetToken, 'token-abc-123');
    });

    test('supports const constructor', () {
      const result = PasswordResetVerificationResult(
        resetToken: 'token-abc-123',
      );

      expect(result.resetToken, 'token-abc-123');
    });
  });
}
