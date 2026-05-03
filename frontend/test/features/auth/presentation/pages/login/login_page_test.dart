import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/login/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

const _anonUser = AuthUserEntity(
  uid: 'anon',
  providerId: 'anonymous',
  isAnonymous: true,
);

Widget _buildPage(AuthBloc bloc) {
  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: const MaterialApp(
      home: LoginPage(),
    ),
  );
}

void main() {
  late MockAuthBloc bloc;

  setUp(() {
    bloc = MockAuthBloc();
    when(() => bloc.state).thenReturn(const AuthAnonymous(_anonUser));
  });

  tearDown(() {
    bloc.close();
  });

  group('LoginPage', () {
    testWidgets('renders email field', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));

      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    });

    testWidgets('renders password field', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));

      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    });

    testWidgets('renders Sign in button', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));

      // AppBar says 'Sign in', button also says 'Sign in' → at least 1
      expect(find.text('Sign in'), findsWidgets);
      // The ElevatedButton with 'Sign in' text exists
      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Sign in'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Google sign-in button', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));

      expect(find.textContaining('Google'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when AuthAuthenticating',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAuthenticating());

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CTA is replaced by progress indicator during AuthAuthenticating',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAuthenticating());

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      // The ElevatedButton CTA with 'Sign in' is replaced by CircularProgressIndicator
      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Sign in'),
        ),
        findsNothing,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows SnackBar when AuthError is emitted', (tester) async {
      const error = AuthException(
        message: 'wrong-password',
        code: 'wrong-password',
      );

      whenListen(
        bloc,
        Stream.fromIterable([
          const AuthAnonymous(_anonUser),
          const AuthError(error, previousState: AuthAnonymous(_anonUser)),
        ]),
        initialState: const AuthAnonymous(_anonUser),
      );

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
