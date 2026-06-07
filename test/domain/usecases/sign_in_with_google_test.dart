import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/usecases/sign_in_with_google.dart';

import '../../mocks/mock_auth_repository.dart';

void main() {
  late SignInWithGoogle useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithGoogle(repository: mockRepository);
  });

  group('SignInWithGoogle', () {
    test('calls signInWithGoogle on repository', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => mockUserCredential);

      await useCase.call();

      verify(() => mockRepository.signInWithGoogle()).called(1);
    });

    test('returns UserCredential on success', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => mockUserCredential);

      final result = await useCase.call();

      expect(result, equals(mockUserCredential));
    });

    test('throws exception when repository fails', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenThrow(Exception('Google sign in cancelled'));

      expect(() => useCase.call(), throwsException);
    });

    test('throws exception when user cancels sign in', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenThrow(Exception('Sign in cancelled by user'));

      expect(() => useCase.call(), throwsException);
    });

    test('throws exception when network error occurs', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenThrow(Exception('Network error'));

      expect(() => useCase.call(), throwsException);
    });
  });
}
