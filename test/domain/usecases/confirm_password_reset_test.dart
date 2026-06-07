import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/usecases/confirm_password_reset.dart';

import '../../mocks/mock_auth_repository.dart';

void main() {
  late ConfirmPasswordReset useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ConfirmPasswordReset(repository: mockRepository);
  });

  group('ConfirmPasswordReset', () {
    test('calls confirmPasswordReset on repository', () async {
      when(
        () => mockRepository.confirmPasswordReset(
          resetToken: any(named: 'resetToken'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async {});

      await useCase.call(resetToken: 'reset-token', newPassword: 'newPassword123');

      verify(
        () => mockRepository.confirmPasswordReset(
          resetToken: 'reset-token',
          newPassword: 'newPassword123',
        ),
      ).called(1);
    });

    test('completes successfully', () async {
      when(
        () => mockRepository.confirmPasswordReset(
          resetToken: any(named: 'resetToken'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async {});

      await expectLater(
        useCase.call(resetToken: 'reset-token', newPassword: 'newPassword123'),
        completes,
      );
    });

    test('throws exception when repository fails', () async {
      when(
        () => mockRepository.confirmPasswordReset(
          resetToken: any(named: 'resetToken'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenThrow(Exception('Invalid reset token'));

      expect(
        () => useCase.call(resetToken: 'invalid', newPassword: 'newPassword123'),
        throwsException,
      );
    });
  });
}
