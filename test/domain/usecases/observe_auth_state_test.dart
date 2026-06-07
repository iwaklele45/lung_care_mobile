import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/domain/usecases/observe_auth_state.dart';

import '../../mocks/mock_auth_repository.dart';

void main() {
  late ObserveAuthState useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ObserveAuthState(repository: mockRepository);
  });

  group('ObserveAuthState', () {
    group('call', () {
      test('returns stream from authStateChanges', () async {
        final controller = StreamController<User?>();
        when(() => mockRepository.authStateChanges())
            .thenAnswer((_) => controller.stream);

        final stream = useCase.call();

        expect(stream, isA<Stream<User?>>());

        final subscription = stream.listen((_) {});

        controller.add(mockUser);
        await Future<void>.delayed(Duration.zero);

        controller.add(null);
        await Future<void>.delayed(Duration.zero);

        await subscription.cancel();
        await controller.close();
      });

      test('returns empty stream when no auth state changes', () async {
        when(() => mockRepository.authStateChanges())
            .thenAnswer((_) => const Stream<User?>.empty());

        final stream = useCase.call();

        await expectLater(stream, emitsDone);
      });

      test('emits multiple auth state changes', () async {
        final controller = StreamController<User?>();
        when(() => mockRepository.authStateChanges())
            .thenAnswer((_) => controller.stream);

        final stream = useCase.call();
        final emissions = <User?>[];

        final subscription = stream.listen((user) => emissions.add(user));

        controller.add(mockUser);
        await Future<void>.delayed(Duration.zero);

        controller.add(null);
        await Future<void>.delayed(Duration.zero);

        expect(emissions, hasLength(2));
        expect(emissions[0], equals(mockUser));
        expect(emissions[1], isNull);

        await subscription.cancel();
        await controller.close();
      });
    });

    group('currentUser', () {
      test('returns current user from repository', () {
        when(() => mockRepository.currentUser).thenReturn(mockUser);

        final user = useCase.currentUser;

        expect(user, equals(mockUser));
        verify(() => mockRepository.currentUser).called(1);
      });

      test('returns null when no user is logged in', () {
        when(() => mockRepository.currentUser).thenReturn(null);

        final user = useCase.currentUser;

        expect(user, isNull);
        verify(() => mockRepository.currentUser).called(1);
      });
    });
  });
}
