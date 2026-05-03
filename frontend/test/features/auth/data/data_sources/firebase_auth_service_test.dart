import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/firebase_auth_service_impl.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockAuthCredential extends Mock implements AuthCredential {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late FirebaseAuthService service;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    service = FirebaseAuthServiceImpl(mockFirebaseAuth);
  });

  group('FirebaseAuthService', () {
    group('signInAnonymously', () {
      test('returns User on success', () async {
        final mockCredential = MockUserCredential();
        final mockUser = MockUser();
        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockFirebaseAuth.signInAnonymously())
            .thenAnswer((_) async => mockCredential);

        final result = await service.signInAnonymously();

        expect(result, equals(mockUser));
      });

      test('throws AuthException on FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.signInAnonymously()).thenThrow(
          FirebaseAuthException(code: 'network-request-failed'),
        );

        expect(
          () => service.signInAnonymously(),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('signInWithEmail', () {
      test('returns User on success', () async {
        final mockCredential = MockUserCredential();
        final mockUser = MockUser();
        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        final result =
            await service.signInWithEmail('user@example.com', 'pass123');

        expect(result, equals(mockUser));
      });

      test('throws AuthException with code on wrong-password', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        try {
          await service.signInWithEmail('user@example.com', 'wrong');
          fail('Expected AuthException');
        } catch (e) {
          expect(e, isA<AuthException>());
          expect((e as AuthException).code, equals('wrong-password'));
        }
      });
    });

    group('signUpWithEmail', () {
      test('returns User on success', () async {
        final mockCredential = MockUserCredential();
        final mockUser = MockUser();
        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        final result =
            await service.signUpWithEmail('new@example.com', 'pass123');

        expect(result, equals(mockUser));
      });

      test('throws AuthException on email-already-in-use', () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(
          FirebaseAuthException(code: 'email-already-in-use'),
        );

        expect(
          () => service.signUpWithEmail('existing@example.com', 'pass123'),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('signInWithCredential', () {
      test('returns User on success', () async {
        final mockCredential = MockUserCredential();
        final mockUser = MockUser();
        final mockAuthCredential = MockAuthCredential();
        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockFirebaseAuth.signInWithCredential(mockAuthCredential))
            .thenAnswer((_) async => mockCredential);

        final result = await service.signInWithCredential(mockAuthCredential);

        expect(result, equals(mockUser));
      });
    });

    group('signOut', () {
      test('calls Firebase signOut', () async {
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        await service.signOut();

        verify(() => mockFirebaseAuth.signOut()).called(1);
      });

      test('throws AuthException on failure', () async {
        when(() => mockFirebaseAuth.signOut()).thenThrow(
          FirebaseAuthException(code: 'internal-error'),
        );

        expect(() => service.signOut(), throwsA(isA<AuthException>()));
      });
    });

    group('sendPasswordResetEmail', () {
      test('calls Firebase sendPasswordResetEmail', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(
              email: any(named: 'email'),
            )).thenAnswer((_) async {});

        await service.sendPasswordResetEmail('user@example.com');

        verify(() => mockFirebaseAuth.sendPasswordResetEmail(
              email: 'user@example.com',
            )).called(1);
      });
    });

    group('currentUser', () {
      test('returns current user from FirebaseAuth', () {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

        final result = service.currentUser;

        expect(result, equals(mockUser));
      });

      test('returns null when no user is signed in', () {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        expect(service.currentUser, isNull);
      });
    });

    group('authStateChanges', () {
      test('returns a stream from FirebaseAuth', () {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(mockUser));

        final stream = service.authStateChanges();

        expect(stream, isA<Stream<User?>>());
      });
    });
  });
}
