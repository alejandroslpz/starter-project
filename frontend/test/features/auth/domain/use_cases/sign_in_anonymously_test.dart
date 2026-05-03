import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_anonymously.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late SignInAnonymouslyUseCase useCase;

  setUp(() {
    repo = MockAuthRepository();
    useCase = SignInAnonymouslyUseCase(repo);
  });

  const anonymousUser = AuthUserEntity(
    uid: 'anon-uid',
    providerId: 'anonymous',
    isAnonymous: true,
  );

  test('returns DataSuccess with AuthUserEntity on successful anonymous sign-in',
      () async {
    when(() => repo.signInAnonymously())
        .thenAnswer((_) async => const DataSuccess(anonymousUser));

    final result = await useCase.call(params: const NoParams());

    expect(result, isA<DataSuccess<AuthUserEntity>>());
    expect(result.data, equals(anonymousUser));
    verify(() => repo.signInAnonymously()).called(1);
  });

  test('returns DataFailed when repository fails', () async {
    when(() => repo.signInAnonymously()).thenAnswer(
      (_) async => const DataFailed(
        AuthException(
          message: 'network error',
          code: 'network-request-failed',
        ),
      ),
    );

    final result = await useCase.call(params: const NoParams());

    expect(result, isA<DataFailed<AuthUserEntity>>());
  });
}
