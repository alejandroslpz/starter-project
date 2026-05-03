import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';

void main() {
  group('SignInParams', () {
    const params = SignInParams(email: 'user@example.com', password: 'pass1234');

    test('constructs with email and password', () {
      expect(params.email, equals('user@example.com'));
      expect(params.password, equals('pass1234'));
    });

    test('two instances with same values are equal (Equatable)', () {
      const params2 =
          SignInParams(email: 'user@example.com', password: 'pass1234');
      expect(params, equals(params2));
    });

    test('instances with different passwords are not equal', () {
      const different =
          SignInParams(email: 'user@example.com', password: 'other');
      expect(params, isNot(equals(different)));
    });
  });

  group('SignUpParams', () {
    const params = SignUpParams(
      email: 'new@example.com',
      password: 'secret123',
      displayName: 'Alice',
    );

    test('constructs with email, password, and displayName', () {
      expect(params.email, equals('new@example.com'));
      expect(params.password, equals('secret123'));
      expect(params.displayName, equals('Alice'));
    });

    test('two instances with same values are equal (Equatable)', () {
      const params2 = SignUpParams(
        email: 'new@example.com',
        password: 'secret123',
        displayName: 'Alice',
      );
      expect(params, equals(params2));
    });

    test('instances with different displayName are not equal', () {
      const different = SignUpParams(
        email: 'new@example.com',
        password: 'secret123',
        displayName: 'Bob',
      );
      expect(params, isNot(equals(different)));
    });
  });
}
