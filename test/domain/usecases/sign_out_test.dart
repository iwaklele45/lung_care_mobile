import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/usecases/sign_out.dart';

import '../../mocks/mock_auth_repository.dart';

void main() {
  late SignOut useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignOut(repository: mockRepository);
  });

  group('SignOut', () {
    test('calls signOut on repository', () async {
      when(() => mockRepository.signOut()).thenAnswer((_) async {});

      await useCase.call();

      verify(() => mockRepository.signOut()).called(1);
    });

    test('completes successfully', () async {
      when(() => mockRepository.signOut()).thenAnswer((_) async {});

      await expectLater(useCase.call(), completes);
    });

    test('throws exception when repository fails', () async {
      when(() => mockRepository.signOut()).thenThrow(Exception('Sign out failed'));

      expect(() => useCase.call(), throwsException);
    });
  });
}
