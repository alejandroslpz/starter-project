import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/send_password_reset.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up_with_email.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _user = AuthUserEntity(
  uid: 'uid-123',
  email: 'user@example.com',
  displayName: 'Test',
  providerId: 'password',
  isAnonymous: false,
);

const _authError = AuthException(
  message: 'wrong-password',
  code: 'wrong-password',
);

void main() {
  late MockAuthRepository repo;

  setUp(() => repo = MockAuthRepository());

  // -------------------------------------------------------------------
  // SignInWithEmail
  // -------------------------------------------------------------------
  group('SignInWithEmailUseCase', () {
    late SignInWithEmailUseCase useCase;
    const params =
        SignInParams(email: 'user@example.com', password: 'pass1234');

    setUp(() => useCase = SignInWithEmailUseCase(repo));

    test('returns DataSuccess on valid credentials', () async {
      when(() => repo.signInWithEmail(params))
          .thenAnswer((_) async => const DataSuccess(_user));

      final result = await useCase.call(params: params);

      expect(result, isA<DataSuccess<AuthUserEntity>>());
      verify(() => repo.signInWithEmail(params)).called(1);
    });

    test('returns DataFailed on wrong password', () async {
      when(() => repo.signInWithEmail(params))
          .thenAnswer((_) async => const DataFailed(_authError));

      final result = await useCase.call(params: params);

      expect(result, isA<DataFailed<AuthUserEntity>>());
    });
  });

  // -------------------------------------------------------------------
  // SignUpWithEmail
  // -------------------------------------------------------------------
  group('SignUpWithEmailUseCase', () {
    late SignUpWithEmailUseCase useCase;
    const params = SignUpParams(
      email: 'new@example.com',
      password: 'pass1234',
      displayName: 'Alice',
    );

    setUp(() => useCase = SignUpWithEmailUseCase(repo));

    test('returns DataSuccess with new user entity', () async {
      when(() => repo.signUpWithEmail(params))
          .thenAnswer((_) async => const DataSuccess(_user));

      final result = await useCase.call(params: params);

      expect(result, isA<DataSuccess<AuthUserEntity>>());
      verify(() => repo.signUpWithEmail(params)).called(1);
    });

    test('returns DataFailed when email already in use', () async {
      const emailInUseError = AuthException(
        message: 'email-already-in-use',
        code: 'email-already-in-use',
      );
      when(() => repo.signUpWithEmail(params))
          .thenAnswer((_) async => const DataFailed(emailInUseError));

      final result = await useCase.call(params: params);

      expect(result, isA<DataFailed<AuthUserEntity>>());
    });
  });

  // -------------------------------------------------------------------
  // SignInWithGoogle
  // -------------------------------------------------------------------
  group('SignInWithGoogleUseCase', () {
    late SignInWithGoogleUseCase useCase;

    setUp(() => useCase = SignInWithGoogleUseCase(repo));

    test('returns DataSuccess with Google user entity', () async {
      when(() => repo.signInWithGoogle())
          .thenAnswer((_) async => const DataSuccess(_user));

      final result = await useCase.call(params: const NoParams());

      expect(result, isA<DataSuccess<AuthUserEntity>>());
    });

    test('returns DataFailed when Google sign-in is cancelled', () async {
      when(() => repo.signInWithGoogle()).thenAnswer(
        (_) async => const DataFailed(
          AuthException(message: 'cancelled', code: 'popup-closed-by-user'),
        ),
      );

      final result = await useCase.call(params: const NoParams());

      expect(result, isA<DataFailed<AuthUserEntity>>());
    });
  });

  // -------------------------------------------------------------------
  // SignOut
  // -------------------------------------------------------------------
  group('SignOutUseCase', () {
    late SignOutUseCase useCase;

    setUp(() => useCase = SignOutUseCase(repo));

    test('returns DataSuccess on sign-out', () async {
      when(() => repo.signOut())
          .thenAnswer((_) async => const DataSuccess(null));

      final result = await useCase.call(params: const NoParams());

      expect(result, isA<DataSuccess<void>>());
      verify(() => repo.signOut()).called(1);
    });
  });

  // -------------------------------------------------------------------
  // SendPasswordReset
  // -------------------------------------------------------------------
  group('SendPasswordResetUseCase', () {
    late SendPasswordResetUseCase useCase;
    const email = 'reset@example.com';

    setUp(() => useCase = SendPasswordResetUseCase(repo));

    test('returns DataSuccess when email is sent', () async {
      when(() => repo.sendPasswordResetEmail(email))
          .thenAnswer((_) async => const DataSuccess(null));

      final result = await useCase.call(params: email);

      expect(result, isA<DataSuccess<void>>());
      verify(() => repo.sendPasswordResetEmail(email)).called(1);
    });

    test('returns DataFailed when user is not found', () async {
      when(() => repo.sendPasswordResetEmail(email)).thenAnswer(
        (_) async => const DataFailed(
          AuthException(message: 'user-not-found', code: 'user-not-found'),
        ),
      );

      final result = await useCase.call(params: email);

      expect(result, isA<DataFailed<void>>());
    });
  });
}
