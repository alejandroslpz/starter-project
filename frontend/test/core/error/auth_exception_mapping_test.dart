import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';

void main() {
  group('AuthException.localizedMessage — Firebase error code mapping', () {
    test('wrong-password returns correct message', () {
      const e = AuthException(
        message: 'wrong-password',
        code: 'wrong-password',
      );
      expect(e.localizedMessage, equals('Email or password is incorrect.'));
    });

    test('invalid-credential returns correct message', () {
      const e = AuthException(
        message: 'invalid-credential',
        code: 'invalid-credential',
      );
      expect(e.localizedMessage, equals('Email or password is incorrect.'));
    });

    test('email-already-in-use returns correct message', () {
      const e = AuthException(
        message: 'email-already-in-use',
        code: 'email-already-in-use',
      );
      expect(
        e.localizedMessage,
        equals('An account with this email already exists.'),
      );
    });

    test('user-not-found returns correct message', () {
      const e = AuthException(
        message: 'user-not-found',
        code: 'user-not-found',
      );
      expect(e.localizedMessage, equals('No account exists for this email.'));
    });

    test('weak-password returns correct message', () {
      const e = AuthException(
        message: 'weak-password',
        code: 'weak-password',
      );
      expect(
        e.localizedMessage,
        equals('Password must be at least 8 characters.'),
      );
    });

    test('network-request-failed returns correct message', () {
      const e = AuthException(
        message: 'network-request-failed',
        code: 'network-request-failed',
      );
      expect(e.localizedMessage, equals('No internet connection.'));
    });

    test('popup-closed-by-user returns correct message', () {
      const e = AuthException(
        message: 'popup-closed-by-user',
        code: 'popup-closed-by-user',
      );
      expect(e.localizedMessage, equals('Sign-in cancelled.'));
    });

    test('unknown code returns default message', () {
      const e = AuthException(
        message: 'some-unknown-error',
        code: 'some-unknown-error',
      );
      expect(
        e.localizedMessage,
        equals('Sign-in failed. Please try again.'),
      );
    });

    test('null code returns default message', () {
      const e = AuthException(message: 'error without code');
      expect(
        e.localizedMessage,
        equals('Sign-in failed. Please try again.'),
      );
    });
  });
}
