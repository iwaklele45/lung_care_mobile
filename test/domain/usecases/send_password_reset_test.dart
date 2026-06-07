import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/usecases/send_password_reset.dart';

import '../../mocks/mock_auth_repository.dart';

void main() {
  late SendPasswordReset useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SendPasswordReset(repository: mockRepository);
  });

  group('SendPasswordReset', () {
    test('calls sendPasswordResetEmail on repository', () async {
      when(() => mockRepository.sendPasswordResetEmail(email: any(named: 'email')))
          .thenAnswer((_) async {});

      await useCase.call(email: 'test@example.com');

      verify(() => mockRepository.sendPasswordResetEmail(email: 'test@example.com'))
          .called(1);
    });

    test('completes successfully', () async {
      when(() => mockRepository.sendPasswordResetEmail(email: any(named: 'email')))
          .thenAnswer((_) async {});

      await expectLater(useCase.call(email: 'test@example.com'), completes);
    });

    test('throws exception when repository fails', () async {
      when(() => mockRepository.sendPasswordResetEmail(email: any(named: 'email')))
          .thenThrow(Exception('Email not found'));

      expect(
        () => useCase.call(email: 'test@example.com'),
        throwsException,
      );
    });
  });
}
