import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/firebase_auth_service_impl.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late FirebaseAuthService service;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    service = FirebaseAuthServiceImpl(mockFirebaseAuth);
  });

  group('FirebaseAuthService', () {
    test('signInAnonymously unwraps the User from UserCredential', () async {
      final mockCredential = MockUserCredential();
      final mockUser = MockUser();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockFirebaseAuth.signInAnonymously())
          .thenAnswer((_) async => mockCredential);

      expect(await service.signInAnonymously(), equals(mockUser));
    });

    test('signInWithEmail forwards credentials and unwraps User', () async {
      final mockCredential = MockUserCredential();
      final mockUser = MockUser();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      expect(
        await service.signInWithEmail('u@example.com', 'pass1234'),
        equals(mockUser),
      );
    });

    test(
        'maps FirebaseAuthException to AuthException preserving the code',
        () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      try {
        await service.signInWithEmail('u@example.com', 'wrong');
        fail('Expected AuthException');
      } catch (e) {
        expect(e, isA<AuthException>());
        expect((e as AuthException).code, equals('wrong-password'));
      }
    });

    test('signOut delegates to Firebase', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await service.signOut();

      verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    test('reloadCurrentUser returns null and signs out on stale user',
        () async {
      final mockUser = MockUser();
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.reload())
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      final result = await service.reloadCurrentUser();

      expect(result, isNull);
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });
  });
}
