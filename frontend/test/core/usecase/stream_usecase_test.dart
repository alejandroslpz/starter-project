import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/usecase/stream_usecase.dart';

// Concrete implementation for testing the abstract contract.
class _FakeStreamUseCase extends StreamUseCase<String, int> {
  @override
  Stream<String> call({int? params}) {
    return Stream.value('value-${params ?? 0}');
  }
}

void main() {
  group('StreamUseCase', () {
    test('call() returns a Stream', () {
      final useCase = _FakeStreamUseCase();

      final result = useCase.call(params: 1);

      expect(result, isA<Stream<String>>());
    });

    test('call() emits values from the stream', () async {
      final useCase = _FakeStreamUseCase();

      final result = await useCase.call(params: 42).first;

      expect(result, equals('value-42'));
    });

    test('call() with null params uses default', () async {
      final useCase = _FakeStreamUseCase();

      final result = await useCase.call().first;

      expect(result, equals('value-0'));
    });
  });
}
