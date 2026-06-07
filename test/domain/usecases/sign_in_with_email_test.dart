import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/usecases/sign_in_with_email.dart';

import '../../mocks/mock_auth_repository.dart';

void main() {
  late SignInWithEmail useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithEmail(repository: mockRepository);
  });

  group('SignInWithEmail', () {
    test('calls signInWithEmailAndPassword on repository', () async {
      when(
        () => mockRepository.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      await useCase.call(email: 'test@example.com', password: 'password123');

      verify(
        () => mockRepository.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('returns UserCredential on success', () async {
      when(
        () => mockRepository.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      final result = await useCase.call(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, equals(mockUserCredential));
    });

    test('throws exception when repository fails', () async {
      when(
        () => mockRepository.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('Invalid credentials'));

      expect(
        () => useCase.call(email: 'test@example.com', password: 'wrong'),
        throwsException,
      );
    });
  });
}
