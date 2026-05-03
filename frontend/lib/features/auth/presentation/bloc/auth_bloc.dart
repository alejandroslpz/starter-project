import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/send_password_reset.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_anonymously.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_auth_state.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Global auth BLoC — single source of truth for auth state (design D1).
///
/// Key behaviors:
/// - Each Sign* handler emits [AuthAuthenticating] SYNCHRONOUSLY as first
///   line (design D11 — optimistic UI).
/// - [WatchAuthStateEvent] subscribes to the auth stream; null emission
///   triggers auto-anonymous sign-in (design D10).
/// - Stream subscription is cancelled in [close()] to prevent leaks.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final WatchAuthStateUseCase _watchAuthState;
  final SignInAnonymouslyUseCase _signInAnonymously;
  final SignInWithEmailUseCase _signInWithEmail;
  final SignUpWithEmailUseCase _signUpWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOut;
  final SendPasswordResetUseCase _sendPasswordReset;

  StreamSubscription<dynamic>? _authSubscription;

  AuthBloc(
    this._watchAuthState,
    this._signInAnonymously,
    this._signInWithEmail,
    this._signUpWithEmail,
    this._signInWithGoogle,
    this._signOut,
    this._sendPasswordReset,
  ) : super(const AuthInitial()) {
    on<WatchAuthStateEvent>(_onWatchAuthState);
    on<SignInAnonymouslyEvent>(_onSignInAnonymously);
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
    on<SendPasswordResetEvent>(_onSendPasswordReset);
    on<ErrorDismissedEvent>(_onErrorDismissed);
  }

  // -------------------------------------------------------------------
  // Handlers
  // -------------------------------------------------------------------

  Future<void> _onWatchAuthState(
    WatchAuthStateEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthAuthenticating());

    await emit.onEach<dynamic>(
      _watchAuthState.call(params: const NoParams()),
      onData: (user) {
        if (user == null) {
          // No user — trigger anonymous sign-in
          add(SignInAnonymouslyEvent());
        } else {
          // User is signed in — determine state from entity
          if (user.isAnonymous) {
            emit(AuthAnonymous(user));
          } else {
            emit(AuthAuthenticated(user));
          }
        }
      },
      onError: (error, stackTrace) {
        emit(AuthError(
          error is Exception
              ? error as dynamic
              : Exception(error.toString()),
          previousState: state,
        ));
      },
    );
  }

  Future<void> _onSignInAnonymously(
    SignInAnonymouslyEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthAuthenticating()); // optimistic, synchronous

    final result = await _signInAnonymously.call(params: const NoParams());
    if (result is DataSuccess) {
      emit(AuthAnonymous(result.data!));
    } else if (result is DataFailed) {
      emit(AuthError(result.error!, previousState: state));
    }
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthAuthenticating()); // optimistic, synchronous

    final result = await _signInWithEmail.call(params: event.params);
    if (result is DataSuccess) {
      emit(AuthAuthenticated(result.data!));
    } else if (result is DataFailed) {
      emit(AuthError(result.error!, previousState: state));
    }
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthAuthenticating()); // optimistic, synchronous

    final result = await _signUpWithEmail.call(params: event.params);
    if (result is DataSuccess) {
      emit(AuthAuthenticated(result.data!));
    } else if (result is DataFailed) {
      emit(AuthError(result.error!, previousState: state));
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthAuthenticating()); // optimistic, synchronous

    final result = await _signInWithGoogle.call(params: const NoParams());
    if (result is DataSuccess) {
      emit(AuthAuthenticated(result.data!));
    } else if (result is DataFailed) {
      final error = result.error!;
      if (error is AuthException && error.code == 'popup-closed-by-user') {
        // Google sign-in cancelled — revert to anonymous without showing error
        final prevState = state;
        if (prevState is AuthAnonymous) {
          emit(AuthAnonymous(prevState.user));
        } else {
          // Re-trigger anonymous if not already anonymous
          add(SignInAnonymouslyEvent());
        }
      } else {
        emit(AuthError(error, previousState: state));
      }
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthAuthenticating()); // optimistic, synchronous

    final result = await _signOut.call(params: const NoParams());
    if (result is DataSuccess) {
      emit(const AuthUnauthenticated());
      // Auto re-anonymous (design D1, SD3)
      add(SignInAnonymouslyEvent());
    } else if (result is DataFailed) {
      emit(AuthError(result.error!, previousState: state));
    }
  }

  Future<void> _onSendPasswordReset(
    SendPasswordResetEvent event,
    Emitter<AuthState> emit,
  ) async {
    // No state transition on success — just fire and forget
    await _sendPasswordReset.call(params: event.email);
  }

  void _onErrorDismissed(
    ErrorDismissedEvent event,
    Emitter<AuthState> emit,
  ) {
    final currentState = state;
    if (currentState is AuthError) {
      emit(currentState.previousState);
    }
  }

  // -------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
