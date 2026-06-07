import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/data/services/profile_storage_service.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

void main() {
  late ProfileStorageService service;
  late MockFirebaseStorage mockStorage;
  late MockReference mockReference;

  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockReference = MockReference();
    service = ProfileStorageService(storage: mockStorage);
  });

  group('ProfileStorageService', () {
    group('delete', () {
      test('calls delete on reference', () async {
        when(() => mockStorage.ref()).thenReturn(mockReference);
        when(() => mockReference.child('profile_pictures/user-123.jpg'))
            .thenReturn(mockReference);
        when(() => mockReference.delete()).thenAnswer((_) async {});

        await service.delete('user-123');

        verify(() => mockReference.delete()).called(1);
      });

      test('swallows object-not-found error', () async {
        when(() => mockStorage.ref()).thenReturn(mockReference);
        when(() => mockReference.child(any())).thenReturn(mockReference);
        when(() => mockReference.delete()).thenThrow(
          FirebaseException(
            plugin: 'storage',
            code: 'object-not-found',
            message: 'No object exists at the desired location',
          ),
        );

        // Should not throw
        await service.delete('user-123');

        verify(() => mockReference.delete()).called(1);
      });

      test('rethrows other Firebase exceptions', () async {
        when(() => mockStorage.ref()).thenReturn(mockReference);
        when(() => mockReference.child(any())).thenReturn(mockReference);
        when(() => mockReference.delete()).thenThrow(
          FirebaseException(
            plugin: 'storage',
            code: 'unauthorized',
            message: 'User is not authorized',
          ),
        );

        expect(
          () => service.delete('user-123'),
          throwsException,
        );
      });

      test('rethrows generic exceptions', () async {
        when(() => mockStorage.ref()).thenReturn(mockReference);
        when(() => mockReference.child(any())).thenReturn(mockReference);
        when(() => mockReference.delete())
            .thenThrow(Exception('Network error'));

        expect(
          () => service.delete('user-123'),
          throwsException,
        );
      });
    });

    group('constructor', () {
      test('creates instance with injected storage', () {
        final service = ProfileStorageService(storage: mockStorage);
        expect(service, isA<ProfileStorageService>());
      });
    });
  });
}
