import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/signup/signup_page.dart';

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
    child: const MaterialApp(home: SignupPage()),
  );
}

void main() {
  late MockAuthBloc bloc;

  setUp(() {
    bloc = MockAuthBloc();
    when(() => bloc.state).thenReturn(const AuthAnonymous(_anonUser));
  });

  tearDown(() => bloc.close());

  group('SignupPage', () {
    testWidgets('renders displayName field', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));
      expect(find.byKey(const Key('signup_displayname_field')), findsOneWidget);
    });

    testWidgets('renders email field', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));
      expect(find.byKey(const Key('signup_email_field')), findsOneWidget);
    });

    testWidgets('renders password field', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));
      expect(find.byKey(const Key('signup_password_field')), findsOneWidget);
    });

    testWidgets('renders Create account button', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));
      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Create account'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows CircularProgressIndicator when AuthAuthenticating',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAuthenticating());

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'CTA is replaced by progress indicator during AuthAuthenticating',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAuthenticating());

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Create account'),
        ),
        findsNothing,
      );
    });
  });
}
