import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    // -------------------------------------------------------------------
    // validateEmail
    // -------------------------------------------------------------------
    group('validateEmail', () {
      test('returns null for valid email', () {
        expect(AuthValidators.validateEmail('user@example.com'), isNull);
      });

      test('returns error for empty string', () {
        expect(AuthValidators.validateEmail(''), isNotNull);
      });

      test('returns error for null', () {
        expect(AuthValidators.validateEmail(null), isNotNull);
      });

      test('returns error for missing @', () {
        expect(AuthValidators.validateEmail('notanemail'), isNotNull);
      });

      test('returns error for missing domain', () {
        expect(AuthValidators.validateEmail('user@'), isNotNull);
      });

      test('accepts subdomain email', () {
        expect(AuthValidators.validateEmail('user@mail.example.co.uk'), isNull);
      });
    });

    // -------------------------------------------------------------------
    // validatePassword
    // -------------------------------------------------------------------
    group('validatePassword', () {
      test('returns null for 8+ character password', () {
        expect(AuthValidators.validatePassword('12345678'), isNull);
      });

      test('returns error for empty string', () {
        expect(AuthValidators.validatePassword(''), isNotNull);
      });

      test('returns error for null', () {
        expect(AuthValidators.validatePassword(null), isNotNull);
      });

      test('returns error for password shorter than 8 chars', () {
        expect(AuthValidators.validatePassword('1234567'), isNotNull);
      });

      test('error message mentions 8 characters', () {
        final error = AuthValidators.validatePassword('short');
        expect(error, contains('8'));
      });
    });

    // -------------------------------------------------------------------
    // validateDisplayName
    // -------------------------------------------------------------------
    group('validateDisplayName', () {
      test('returns null for 2+ character name', () {
        expect(AuthValidators.validateDisplayName('Al'), isNull);
      });

      test('returns error for empty string', () {
        expect(AuthValidators.validateDisplayName(''), isNotNull);
      });

      test('returns error for null', () {
        expect(AuthValidators.validateDisplayName(null), isNotNull);
      });

      test('returns error for single character name', () {
        expect(AuthValidators.validateDisplayName('A'), isNotNull);
      });
    });
  });
}
