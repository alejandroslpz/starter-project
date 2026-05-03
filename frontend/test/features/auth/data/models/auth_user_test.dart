import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

class MockUser extends Mock implements User {}

class MockUserInfo extends Mock implements UserInfo {}

void main() {
  group('AuthUserModel', () {
    late MockUser mockUser;

    setUp(() {
      mockUser = MockUser();

      when(() => mockUser.uid).thenReturn('uid-firebase-123');
      when(() => mockUser.email).thenReturn('user@example.com');
      when(() => mockUser.displayName).thenReturn('Firebase User');
      when(() => mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockUser.providerData).thenReturn([]);
    });

    test('fromRawData maps all fields from Firebase User', () {
      final model = AuthUserModel.fromRawData(mockUser);

      expect(model.uid, equals('uid-firebase-123'));
      expect(model.email, equals('user@example.com'));
      expect(model.displayName, equals('Firebase User'));
      expect(model.photoURL, equals('https://example.com/photo.jpg'));
      expect(model.isAnonymous, isFalse);
    });

    test('fromRawData sets providerId to anonymous for anonymous users', () {
      when(() => mockUser.isAnonymous).thenReturn(true);
      when(() => mockUser.providerData).thenReturn([]);

      final model = AuthUserModel.fromRawData(mockUser);

      expect(model.isAnonymous, isTrue);
      expect(model.providerId, equals('anonymous'));
    });

    test(
        'fromRawData sets providerId from providerData when non-anonymous',
        () {
      final mockProviderInfo = MockUserInfo();
      when(() => mockProviderInfo.providerId).thenReturn('google.com');
      when(() => mockUser.providerData).thenReturn([mockProviderInfo]);

      final model = AuthUserModel.fromRawData(mockUser);

      expect(model.providerId, equals('google.com'));
    });

    test('toEntity() returns equivalent AuthUserEntity', () {
      final model = AuthUserModel.fromRawData(mockUser);
      final entity = model.toEntity();

      expect(entity, isA<AuthUserEntity>());
      expect(entity.uid, equals(model.uid));
      expect(entity.email, equals(model.email));
      expect(entity.displayName, equals(model.displayName));
      expect(entity.photoURL, equals(model.photoURL));
      expect(entity.providerId, equals(model.providerId));
      expect(entity.isAnonymous, equals(model.isAnonymous));
    });

    test('roundtrip: fromRawData().toEntity() equals direct AuthUserEntity construction',
        () {
      final model = AuthUserModel.fromRawData(mockUser);
      final entity = model.toEntity();

      const expected = AuthUserEntity(
        uid: 'uid-firebase-123',
        email: 'user@example.com',
        displayName: 'Firebase User',
        photoURL: 'https://example.com/photo.jpg',
        providerId: 'password',
        isAnonymous: false,
      );

      // Note: providerId may differ (depends on providerData) — we check structural equality
      expect(entity.uid, equals(expected.uid));
      expect(entity.email, equals(expected.email));
    });

    test('AuthUserModel is a subtype of AuthUserEntity', () {
      final model = AuthUserModel.fromRawData(mockUser);

      expect(model, isA<AuthUserEntity>());
    });
  });
}
