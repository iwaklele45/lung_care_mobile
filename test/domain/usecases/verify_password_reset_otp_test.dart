import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/usecases/verify_password_reset_otp.dart';

import '../../mocks/mock_auth_repository.dart';

void main() {
  late VerifyPasswordResetOtp useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = VerifyPasswordResetOtp(repository: mockRepository);
  });

  group('VerifyPasswordResetOtp', () {
    test('calls verifyPasswordResetOtp on repository', () async {
      final expectedResult = createMockPasswordResetVerificationResult();
      when(
        () => mockRepository.verifyPasswordResetOtp(
          requestId: any(named: 'requestId'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async => expectedResult);

      await useCase.call(requestId: 'request-1', code: '123456');

      verify(
        () => mockRepository.verifyPasswordResetOtp(
          requestId: 'request-1',
          code: '123456',
        ),
      ).called(1);
    });

    test('returns PasswordResetVerificationResult on success', () async {
      final expectedResult = createMockPasswordResetVerificationResult();
      when(
        () => mockRepository.verifyPasswordResetOtp(
          requestId: any(named: 'requestId'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async => expectedResult);

      final result = await useCase.call(
        requestId: 'request-1',
        code: '123456',
      );

      expect(result, equals(expectedResult));
    });

    test('throws exception when repository fails', () async {
      when(
        () => mockRepository.verifyPasswordResetOtp(
          requestId: any(named: 'requestId'),
          code: any(named: 'code'),
        ),
      ).thenThrow(Exception('Invalid code'));

      expect(
        () => useCase.call(requestId: 'request-1', code: '000000'),
        throwsException,
      );
    });
  });
}
