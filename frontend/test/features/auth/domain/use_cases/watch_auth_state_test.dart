import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late WatchAuthStateUseCase useCase;

  setUp(() {
    repo = MockAuthRepository();
    useCase = WatchAuthStateUseCase(repo);
  });

  const user = AuthUserEntity(
    uid: 'uid-123',
    providerId: 'password',
    isAnonymous: false,
  );

  test('returns a Stream from repository.watchAuthState()', () {
    when(() => repo.watchAuthState()).thenAnswer(
      (_) => Stream.value(user),
    );

    final result = useCase.call(params: const NoParams());

    expect(result, isA<Stream<AuthUserEntity?>>());
    verify(() => repo.watchAuthState()).called(1);
  });

  test('emits AuthUserEntity when user is signed in', () async {
    when(() => repo.watchAuthState()).thenAnswer(
      (_) => Stream.value(user),
    );

    final emitted = await useCase.call(params: const NoParams()).first;

    expect(emitted, equals(user));
  });

  test('emits null when user signs out', () async {
    when(() => repo.watchAuthState()).thenAnswer(
      (_) => Stream<AuthUserEntity?>.value(null),
    );

    final emitted = await useCase.call(params: const NoParams()).first;

    expect(emitted, isNull);
  });
}
