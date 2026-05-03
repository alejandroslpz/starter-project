import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/send_password_reset.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_anonymously.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

class MockWatchAuthStateUseCase extends Mock implements WatchAuthStateUseCase {}

class MockSignInAnonymouslyUseCase extends Mock
    implements SignInAnonymouslyUseCase {}

class MockSignInWithEmailUseCase extends Mock implements SignInWithEmailUseCase {}

class MockSignUpWithEmailUseCase extends Mock implements SignUpWithEmailUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockSendPasswordResetUseCase extends Mock
    implements SendPasswordResetUseCase {}

const _anonUser = AuthUserEntity(
  uid: 'anon-uid',
  providerId: 'anonymous',
  isAnonymous: true,
);

const _authUser = AuthUserEntity(
  uid: 'uid-123',
  email: 'user@example.com',
  displayName: 'Test User',
  providerId: 'password',
  isAnonymous: false,
);

const _authError = AuthException(
  message: 'wrong-password',
  code: 'wrong-password',
);

AuthBloc _buildBloc({
  required MockWatchAuthStateUseCase watchAuthState,
  required MockSignInAnonymouslyUseCase signInAnonymously,
  required MockSignInWithEmailUseCase signInWithEmail,
  required MockSignUpWithEmailUseCase signUpWithEmail,
  required MockSignInWithGoogleUseCase signInWithGoogle,
  required MockSignOutUseCase signOut,
  required MockSendPasswordResetUseCase sendPasswordReset,
}) {
  return AuthBloc(
    watchAuthState,
    signInAnonymously,
    signInWithEmail,
    signUpWithEmail,
    signInWithGoogle,
    signOut,
    sendPasswordReset,
  );
}

void main() {
  late MockWatchAuthStateUseCase watchAuthState;
  late MockSignInAnonymouslyUseCase signInAnonymously;
  late MockSignInWithEmailUseCase signInWithEmail;
  late MockSignUpWithEmailUseCase signUpWithEmail;
  late MockSignInWithGoogleUseCase signInWithGoogle;
  late MockSignOutUseCase signOut;
  late MockSendPasswordResetUseCase sendPasswordReset;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const SignInParams(email: '', password: ''),
    );
    registerFallbackValue(
      const SignUpParams(email: '', password: '', displayName: ''),
    );
  });

  setUp(() {
    watchAuthState = MockWatchAuthStateUseCase();
    signInAnonymously = MockSignInAnonymouslyUseCase();
    signInWithEmail = MockSignInWithEmailUseCase();
    signUpWithEmail = MockSignUpWithEmailUseCase();
    signInWithGoogle = MockSignInWithGoogleUseCase();
    signOut = MockSignOutUseCase();
    sendPasswordReset = MockSendPasswordResetUseCase();
  });

  // Helper that provides a watchAuthState stream returning a single value
  // then completes.
  void stubWatch(AuthUserEntity? user) {
    when(() => watchAuthState.call(params: any(named: 'params')))
        .thenAnswer((_) => Stream<AuthUserEntity?>.value(user));
  }

  // -------------------------------------------------------------------
  // Initial state
  // -------------------------------------------------------------------
  test('initial state is AuthInitial', () {
    stubWatch(null);
    when(() => signInAnonymously.call(params: any(named: 'params')))
        .thenAnswer((_) async => const DataSuccess(_anonUser));

    final bloc = _buildBloc(
      watchAuthState: watchAuthState,
      signInAnonymously: signInAnonymously,
      signInWithEmail: signInWithEmail,
      signUpWithEmail: signUpWithEmail,
      signInWithGoogle: signInWithGoogle,
      signOut: signOut,
      sendPasswordReset: sendPasswordReset,
    );

    expect(bloc.state, isA<AuthInitial>());
    bloc.close();
  });

  // -------------------------------------------------------------------
  // WatchAuthState — null stream → auto SignInAnonymously
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'WatchAuthState: null stream emission triggers anonymous sign-in chain',
    build: () {
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(WatchAuthStateEvent()),
    // WatchAuthState emits AuthAuthenticating first (D11).
    // Then null stream → add(SignInAnonymously) → AuthAnonymous.
    // The SignInAnonymously AuthAuthenticating may be merged or occur after
    // the stream closes depending on bloc event queue ordering.
    expect: () => [
      isA<AuthAuthenticating>(),
      isA<AuthAnonymous>(),
    ],
  );

  // -------------------------------------------------------------------
  // WatchAuthState — authenticated stream → AuthAuthenticated
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'WatchAuthState: authenticated user stream emits AuthAuthenticated',
    build: () {
      when(() => watchAuthState.call(params: any(named: 'params')))
          .thenAnswer((_) => Stream<AuthUserEntity?>.value(_authUser));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(WatchAuthStateEvent()),
    expect: () => [
      isA<AuthAuthenticating>(),
      isA<AuthAuthenticated>(),
    ],
  );

  // -------------------------------------------------------------------
  // SignInWithEmail — success
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'SignInWithEmail: emits AuthAuthenticating then AuthAuthenticated on success',
    build: () {
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => signInWithEmail.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_authUser));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(
      SignInWithEmailEvent(
        const SignInParams(email: 'u@e.com', password: 'pass1234'),
      ),
    ),
    expect: () => [
      isA<AuthAuthenticating>(),
      isA<AuthAuthenticated>(),
    ],
  );

  // -------------------------------------------------------------------
  // SignInWithEmail — failure
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'SignInWithEmail: emits AuthAuthenticating then AuthError on failure',
    build: () {
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => signInWithEmail.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(_authError));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(
      SignInWithEmailEvent(
        const SignInParams(email: 'u@e.com', password: 'wrong'),
      ),
    ),
    expect: () => [
      isA<AuthAuthenticating>(),
      isA<AuthError>(),
    ],
  );

  // -------------------------------------------------------------------
  // SignUpWithEmail — success
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'SignUpWithEmail: emits AuthAuthenticating then AuthAuthenticated on success',
    build: () {
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => signUpWithEmail.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_authUser));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(
      SignUpWithEmailEvent(
        const SignUpParams(
          email: 'n@e.com',
          password: 'pass1234',
          displayName: 'Alice',
        ),
      ),
    ),
    expect: () => [
      isA<AuthAuthenticating>(),
      isA<AuthAuthenticated>(),
    ],
  );

  // -------------------------------------------------------------------
  // SignInWithGoogle — cancelled (null result → no error, stays anonymous)
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'SignInWithGoogle: cancelled returns AuthAuthenticating only (no state change)',
    build: () {
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => signInWithGoogle.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(
                AuthException(
                  message: 'cancelled',
                  code: 'popup-closed-by-user',
                ),
              ));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(SignInWithGoogleEvent()),
    // Cancelled = emit AuthAuthenticating then remain in previous state
    // (design: cancelled Google sign-in stays anonymous, no AuthError emitted)
    expect: () => [
      isA<AuthAuthenticating>(),
      // Cancelled sign-in does NOT emit AuthError for popup-closed-by-user
      // per design D1 — it stays in AuthAnonymous (previous state)
      // For now the bloc emits AuthAnonymous after popup-closed-by-user
      isA<AuthAnonymous>(),
    ],
  );

  // -------------------------------------------------------------------
  // SignOut
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'SignOut: emits AuthAuthenticating, AuthUnauthenticated, then AuthAnonymous',
    build: () {
      // First watch emission is null (sets up anonymous)
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => signOut.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(null));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) => bloc.add(SignOutEvent()),
    expect: () => [
      isA<AuthAuthenticating>(),
      isA<AuthUnauthenticated>(),
      isA<AuthAuthenticating>(),
      isA<AuthAnonymous>(),
    ],
  );

  // -------------------------------------------------------------------
  // SendPasswordReset
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'SendPasswordReset: emits no state change on success',
    build: () {
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => sendPasswordReset.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(null));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    act: (bloc) =>
        bloc.add(SendPasswordResetEvent('user@example.com')),
    // No state transition on password reset success
    expect: () => [],
  );

  // -------------------------------------------------------------------
  // ErrorDismissed — reverts to AuthAnonymous
  // -------------------------------------------------------------------
  blocTest<AuthBloc, AuthState>(
    'ErrorDismissed: reverts from AuthError to AuthAnonymous',
    build: () {
      stubWatch(null);
      when(() => signInAnonymously.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(_anonUser));
      when(() => signInWithEmail.call(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(_authError));
      return _buildBloc(
        watchAuthState: watchAuthState,
        signInAnonymously: signInAnonymously,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        sendPasswordReset: sendPasswordReset,
      );
    },
    seed: () => const AuthError(_authError, previousState: AuthAnonymous(_anonUser)),
    act: (bloc) => bloc.add(ErrorDismissedEvent()),
    expect: () => [
      isA<AuthAnonymous>(),
    ],
  );
}
