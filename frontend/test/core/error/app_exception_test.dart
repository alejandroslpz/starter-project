import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';

void main() {
  group('AppException hierarchy', () {
    group('NetworkException', () {
      test('is constructable with message', () {
        const exception = NetworkException(message: 'No internet connection');

        expect(exception.message, equals('No internet connection'));
      });

      test('carries cause and stackTrace', () {
        final cause = Exception('socket error');
        final stackTrace = StackTrace.current;
        final exception = NetworkException(
          message: 'connection failed',
          cause: cause,
          stackTrace: stackTrace,
        );

        expect(exception.cause, equals(cause));
        expect(exception.stackTrace, equals(stackTrace));
      });

      test('is a subtype of AppException', () {
        const exception = NetworkException(message: 'test');

        expect(exception, isA<AppException>());
      });

      test('localizedMessage returns non-empty string', () {
        const exception = NetworkException(message: 'raw error');

        expect(exception.localizedMessage, isNotEmpty);
      });
    });

    group('FirestoreException', () {
      test('is constructable with message', () {
        const exception = FirestoreException(message: 'document not found');

        expect(exception.message, equals('document not found'));
      });

      test('carries optional code field', () {
        const exception = FirestoreException(
          message: 'permission denied',
          code: 'permission-denied',
        );

        expect(exception.code, equals('permission-denied'));
      });

      test('code is nullable', () {
        const exception = FirestoreException(message: 'error without code');

        expect(exception.code, isNull);
      });

      test('is a subtype of AppException', () {
        const exception = FirestoreException(message: 'test');

        expect(exception, isA<AppException>());
      });
    });

    group('StorageException', () {
      test('is constructable with message', () {
        const exception = StorageException(message: 'upload failed');

        expect(exception.message, equals('upload failed'));
      });

      test('is a subtype of AppException', () {
        const exception = StorageException(message: 'test');

        expect(exception, isA<AppException>());
      });
    });

    group('AuthException', () {
      test('is constructable with message', () {
        const exception = AuthException(message: 'not authenticated');

        expect(exception.message, equals('not authenticated'));
      });

      test('is a subtype of AppException', () {
        const exception = AuthException(message: 'test');

        expect(exception, isA<AppException>());
      });
    });

    group('UnknownException', () {
      test('is constructable with message', () {
        const exception = UnknownException(message: 'unexpected failure');

        expect(exception.message, equals('unexpected failure'));
      });

      test('is a subtype of AppException', () {
        const exception = UnknownException(message: 'test');

        expect(exception, isA<AppException>());
      });
    });

    group('localizedMessage', () {
      test('FirestoreException returns non-empty localizedMessage', () {
        const exception = FirestoreException(message: 'db error');

        expect(exception.localizedMessage, isNotEmpty);
      });

      test('StorageException returns non-empty localizedMessage', () {
        const exception = StorageException(message: 'upload failed');

        expect(exception.localizedMessage, isNotEmpty);
      });

      test('AuthException returns non-empty localizedMessage', () {
        const exception = AuthException(message: 'not authenticated');

        expect(exception.localizedMessage, isNotEmpty);
      });

      test('UnknownException returns non-empty localizedMessage', () {
        const exception = UnknownException(message: 'unexpected');

        expect(exception.localizedMessage, isNotEmpty);
      });
    });

    group('Exhaustive switch', () {
      test('sealed switch covers all subtypes without default branch', () {
        // If a new subtype is added to AppException, this switch
        // will fail to compile — that is the desired property.
        String classify(AppException e) {
          return switch (e) {
            NetworkException() => 'network',
            FirestoreException() => 'firestore',
            StorageException() => 'storage',
            AuthException() => 'auth',
            UnknownException() => 'unknown',
          };
        }

        expect(classify(const NetworkException(message: 'x')), equals('network'));
        expect(classify(const FirestoreException(message: 'x')), equals('firestore'));
        expect(classify(const StorageException(message: 'x')), equals('storage'));
        expect(classify(const AuthException(message: 'x')), equals('auth'));
        expect(classify(const UnknownException(message: 'x')), equals('unknown'));
      });
    });
  });
}
