import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/usecases/check_user_profile.dart';

import '../../mocks/mock_auth_repository.dart';

void main() {
  late CheckUserProfile useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = CheckUserProfile(repository: mockRepository);
  });

  group('CheckUserProfile', () {
    test('calls checkUserProfileExists on repository', () async {
      when(() => mockRepository.checkUserProfileExists(any()))
          .thenAnswer((_) async => true);

      await useCase.call(uid: 'user-123');

      verify(() => mockRepository.checkUserProfileExists('user-123')).called(1);
    });

    test('returns true when profile exists', () async {
      when(() => mockRepository.checkUserProfileExists(any()))
          .thenAnswer((_) async => true);

      final result = await useCase.call(uid: 'user-123');

      expect(result, isTrue);
    });

    test('returns false when profile does not exist', () async {
      when(() => mockRepository.checkUserProfileExists(any()))
          .thenAnswer((_) async => false);

      final result = await useCase.call(uid: 'user-123');

      expect(result, isFalse);
    });

    test('throws exception when repository fails', () async {
      when(() => mockRepository.checkUserProfileExists(any()))
          .thenThrow(Exception('Network error'));

      expect(() => useCase.call(uid: 'user-123'), throwsException);
    });
  });
}
