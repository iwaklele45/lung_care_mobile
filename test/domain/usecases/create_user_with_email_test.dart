import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/usecases/create_user_with_email.dart';

import '../../mocks/mock_auth_repository.dart';

void main() {
  late CreateUserWithEmail useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = CreateUserWithEmail(repository: mockRepository);
  });

  group('CreateUserWithEmail', () {
    test('calls createUserWithEmailAndPassword on repository', () async {
      when(
        () => mockRepository.createUserWithEmailAndPassword(
          fullName: any(named: 'fullName'),
          phoneNumber: any(named: 'phoneNumber'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          address: any(named: 'address'),
          profilePicturePath: any(named: 'profilePicturePath'),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      await useCase.call(
        fullName: 'John Doe',
        phoneNumber: '08123456789',
        email: 'john@example.com',
        password: 'password123',
        address: 'Jakarta',
      );

      verify(
        () => mockRepository.createUserWithEmailAndPassword(
          fullName: 'John Doe',
          phoneNumber: '08123456789',
          email: 'john@example.com',
          password: 'password123',
          address: 'Jakarta',
          profilePicturePath: null,
        ),
      ).called(1);
    });

    test('calls createUserWithEmailAndPassword with profilePicturePath', () async {
      when(
        () => mockRepository.createUserWithEmailAndPassword(
          fullName: any(named: 'fullName'),
          phoneNumber: any(named: 'phoneNumber'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          address: any(named: 'address'),
          profilePicturePath: any(named: 'profilePicturePath'),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      await useCase.call(
        fullName: 'John Doe',
        phoneNumber: '08123456789',
        email: 'john@example.com',
        password: 'password123',
        address: 'Jakarta',
        profilePicturePath: '/path/to/image.jpg',
      );

      verify(
        () => mockRepository.createUserWithEmailAndPassword(
          fullName: 'John Doe',
          phoneNumber: '08123456789',
          email: 'john@example.com',
          password: 'password123',
          address: 'Jakarta',
          profilePicturePath: '/path/to/image.jpg',
        ),
      ).called(1);
    });

    test('returns UserCredential on success', () async {
      when(
        () => mockRepository.createUserWithEmailAndPassword(
          fullName: any(named: 'fullName'),
          phoneNumber: any(named: 'phoneNumber'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          address: any(named: 'address'),
          profilePicturePath: any(named: 'profilePicturePath'),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      final result = await useCase.call(
        fullName: 'John Doe',
        phoneNumber: '08123456789',
        email: 'john@example.com',
        password: 'password123',
        address: 'Jakarta',
      );

      expect(result, equals(mockUserCredential));
    });

    test('throws exception when repository fails', () async {
      when(
        () => mockRepository.createUserWithEmailAndPassword(
          fullName: any(named: 'fullName'),
          phoneNumber: any(named: 'phoneNumber'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          address: any(named: 'address'),
          profilePicturePath: any(named: 'profilePicturePath'),
        ),
      ).thenThrow(Exception('Email already in use'));

      expect(
        () => useCase.call(
          fullName: 'John Doe',
          phoneNumber: '08123456789',
          email: 'john@example.com',
          password: 'password123',
          address: 'Jakarta',
        ),
        throwsException,
      );
    });

    test('throws exception when email format is invalid', () async {
      when(
        () => mockRepository.createUserWithEmailAndPassword(
          fullName: any(named: 'fullName'),
          phoneNumber: any(named: 'phoneNumber'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          address: any(named: 'address'),
          profilePicturePath: any(named: 'profilePicturePath'),
        ),
      ).thenThrow(Exception('Invalid email format'));

      expect(
        () => useCase.call(
          fullName: 'John Doe',
          phoneNumber: '08123456789',
          email: 'invalid-email',
          password: 'password123',
          address: 'Jakarta',
        ),
        throwsException,
      );
    });
  });
}
