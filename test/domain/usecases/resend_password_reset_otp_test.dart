import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/usecases/resend_password_reset_otp.dart';

import '../../mocks/mock_auth_repository.dart';

void main() {
  late ResendPasswordResetOtp useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ResendPasswordResetOtp(repository: mockRepository);
  });

  group('ResendPasswordResetOtp', () {
    test('calls resendPasswordResetOtp on repository', () async {
      final expectedResult = createMockPasswordResetRequestResult();
      when(() => mockRepository.resendPasswordResetOtp(requestId: any(named: 'requestId')))
          .thenAnswer((_) async => expectedResult);

      await useCase.call(requestId: 'request-1');

      verify(() => mockRepository.resendPasswordResetOtp(requestId: 'request-1'))
          .called(1);
    });

    test('returns PasswordResetRequestResult on success', () async {
      final expectedResult = createMockPasswordResetRequestResult();
      when(() => mockRepository.resendPasswordResetOtp(requestId: any(named: 'requestId')))
          .thenAnswer((_) async => expectedResult);

      final result = await useCase.call(requestId: 'request-1');

      expect(result, equals(expectedResult));
    });

    test('throws exception when repository fails', () async {
      when(() => mockRepository.resendPasswordResetOtp(requestId: any(named: 'requestId')))
          .thenThrow(Exception('Request expired'));

      expect(
        () => useCase.call(requestId: 'request-1'),
        throwsException,
      );
    });
  });
}
