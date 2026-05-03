import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

void main() {
  group('AuthUserEntity', () {
    const user = AuthUserEntity(
      uid: 'uid-123',
      email: 'test@example.com',
      displayName: 'Test User',
      photoURL: 'https://example.com/photo.jpg',
      providerId: 'password',
      isAnonymous: false,
    );

    test('constructs with all 6 fields', () {
      expect(user.uid, equals('uid-123'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
      expect(user.photoURL, equals('https://example.com/photo.jpg'));
      expect(user.providerId, equals('password'));
      expect(user.isAnonymous, isFalse);
    });

    test('email, displayName, and photoURL are nullable', () {
      const anonymous = AuthUserEntity(
        uid: 'anon-uid',
        providerId: 'anonymous',
        isAnonymous: true,
      );

      expect(anonymous.email, isNull);
      expect(anonymous.displayName, isNull);
      expect(anonymous.photoURL, isNull);
    });

    test('two entities with same values are equal (Equatable)', () {
      const user2 = AuthUserEntity(
        uid: 'uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        providerId: 'password',
        isAnonymous: false,
      );

      expect(user, equals(user2));
    });

    test('entities with different uid are not equal', () {
      const other = AuthUserEntity(
        uid: 'different-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        providerId: 'password',
        isAnonymous: false,
      );

      expect(user, isNot(equals(other)));
    });

    test('props contains all 6 fields', () {
      expect(user.props.length, equals(6));
    });
  });
}
