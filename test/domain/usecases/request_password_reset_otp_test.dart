import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/usecases/request_password_reset_otp.dart';

import '../../mocks/mock_auth_repository.dart';

void main() {
  late RequestPasswordResetOtp useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RequestPasswordResetOtp(repository: mockRepository);
  });

  group('RequestPasswordResetOtp', () {
    test('calls requestPasswordResetOtp on repository', () async {
      final expectedResult = createMockPasswordResetRequestResult();
      when(() => mockRepository.requestPasswordResetOtp(identifier: any(named: 'identifier')))
          .thenAnswer((_) async => expectedResult);

      await useCase.call(identifier: 'test@example.com');

      verify(() => mockRepository.requestPasswordResetOtp(identifier: 'test@example.com'))
          .called(1);
    });

    test('returns PasswordResetRequestResult on success', () async {
      final expectedResult = createMockPasswordResetRequestResult();
      when(() => mockRepository.requestPasswordResetOtp(identifier: any(named: 'identifier')))
          .thenAnswer((_) async => expectedResult);

      final result = await useCase.call(identifier: 'test@example.com');

      expect(result, equals(expectedResult));
    });

    test('throws exception when repository fails', () async {
      when(() => mockRepository.requestPasswordResetOtp(identifier: any(named: 'identifier')))
          .thenThrow(Exception('User not found'));

      expect(
        () => useCase.call(identifier: 'test@example.com'),
        throwsException,
      );
    });
  });
}
