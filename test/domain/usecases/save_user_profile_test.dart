import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/usecases/save_user_profile.dart';

import '../../mocks/mock_auth_repository.dart';

void main() {
  late SaveUserProfile useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SaveUserProfile(repository: mockRepository);
  });

  group('SaveUserProfile', () {
    test('calls saveUserProfile on repository', () async {
      when(
        () => mockRepository.saveUserProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          phoneNumber: any(named: 'phoneNumber'),
          address: any(named: 'address'),
          email: any(named: 'email'),
          profilePicturePath: any(named: 'profilePicturePath'),
        ),
      ).thenAnswer((_) async {});

      await useCase.call(
        uid: 'user-123',
        name: 'John Doe',
        phoneNumber: '08123456789',
        address: 'Jakarta',
        email: 'john@example.com',
      );

      verify(
        () => mockRepository.saveUserProfile(
          uid: 'user-123',
          name: 'John Doe',
          phoneNumber: '08123456789',
          address: 'Jakarta',
          email: 'john@example.com',
          profilePicturePath: null,
        ),
      ).called(1);
    });

    test('calls saveUserProfile with profilePicturePath', () async {
      when(
        () => mockRepository.saveUserProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          phoneNumber: any(named: 'phoneNumber'),
          address: any(named: 'address'),
          email: any(named: 'email'),
          profilePicturePath: any(named: 'profilePicturePath'),
        ),
      ).thenAnswer((_) async {});

      await useCase.call(
        uid: 'user-123',
        name: 'John Doe',
        phoneNumber: '08123456789',
        address: 'Jakarta',
        email: 'john@example.com',
        profilePicturePath: '/path/to/image.jpg',
      );

      verify(
        () => mockRepository.saveUserProfile(
          uid: 'user-123',
          name: 'John Doe',
          phoneNumber: '08123456789',
          address: 'Jakarta',
          email: 'john@example.com',
          profilePicturePath: '/path/to/image.jpg',
        ),
      ).called(1);
    });

    test('completes successfully', () async {
      when(
        () => mockRepository.saveUserProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          phoneNumber: any(named: 'phoneNumber'),
          address: any(named: 'address'),
          email: any(named: 'email'),
          profilePicturePath: any(named: 'profilePicturePath'),
        ),
      ).thenAnswer((_) async {});

      await expectLater(
        useCase.call(
          uid: 'user-123',
          name: 'John Doe',
          phoneNumber: '08123456789',
          address: 'Jakarta',
          email: 'john@example.com',
        ),
        completes,
      );
    });

    test('throws exception when repository fails', () async {
      when(
        () => mockRepository.saveUserProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          phoneNumber: any(named: 'phoneNumber'),
          address: any(named: 'address'),
          email: any(named: 'email'),
          profilePicturePath: any(named: 'profilePicturePath'),
        ),
      ).thenThrow(Exception('Failed to save profile'));

      expect(
        () => useCase.call(
          uid: 'user-123',
          name: 'John Doe',
          phoneNumber: '08123456789',
          address: 'Jakarta',
          email: 'john@example.com',
        ),
        throwsException,
      );
    });
  });
}
