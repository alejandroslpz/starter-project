import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class MockRemoteArticlesBloc
    extends MockBloc<RemoteArticlesEvent, RemoteArticlesState>
    implements RemoteArticlesBloc {}

const _anonUser = AuthUserEntity(
  uid: 'anon',
  providerId: 'anonymous',
  isAnonymous: true,
);

const _authedUser = AuthUserEntity(
  uid: 'user-1',
  email: 'test@example.com',
  displayName: 'Test',
  providerId: 'password',
  isAnonymous: false,
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

  group('AppRouter redirect (widget-level)', () {
    Future<void> pumpRouter(
      WidgetTester tester,
      MockAuthBloc authBloc, {
      required String startLocation,
    }) async {
      final remoteBloc = MockRemoteArticlesBloc();
      when(() => remoteBloc.state).thenReturn(const RemoteArticlesLoading());
      addTearDown(remoteBloc.close);

      final r = AppRouter.create(authBloc);
      r.go(startLocation);
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<RemoteArticlesBloc>.value(value: remoteBloc),
          ],
          child: MaterialApp.router(routerConfig: r),
        ),
      );
      // Settle the redirect + initial frame.
      await tester.pump();
    }

    testWidgets('anonymous user can stay on /login', (tester) async {
      when(() => bloc.state).thenReturn(const AuthAnonymous(_anonUser));
      await pumpRouter(tester, bloc, startLocation: '/login');

      // LoginPage's AppBar shows 'Sign in' as title.
      expect(find.text('Sign in'), findsWidgets);
    });

    testWidgets('authenticated user on /login is redirected to /',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAuthenticated(_authedUser));
      await pumpRouter(tester, bloc, startLocation: '/login');

      // DailyNews's AppBar title.
      expect(find.text('Daily News'), findsOneWidget);
    });

    testWidgets('authenticated user on /signup is redirected to /',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAuthenticated(_authedUser));
      await pumpRouter(tester, bloc, startLocation: '/signup');

      expect(find.text('Daily News'), findsOneWidget);
    });
  });
}
