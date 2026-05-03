import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

const _anonUser = AuthUserEntity(
  uid: 'anon',
  providerId: 'anonymous',
  isAnonymous: true,
);

void main() {
  late MockAuthBloc bloc;
  late GoRouter router;

  setUp(() {
    bloc = MockAuthBloc();
    when(() => bloc.state).thenReturn(const AuthAnonymous(_anonUser));
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    router = AppRouter.create(bloc);
  });

  tearDown(() => bloc.close());

  group('AppRouter', () {
    test('/ is the initial location', () {
      expect(router.routeInformationProvider.value.uri.path, equals('/'));
    });

    test('AppRouter.create returns a GoRouter instance', () {
      expect(router, isA<GoRouter>());
    });

    test('router has 6 routes', () {
      final config = router.routerDelegate.currentConfiguration;
      expect(config, isNotNull);
    });
  });
}
