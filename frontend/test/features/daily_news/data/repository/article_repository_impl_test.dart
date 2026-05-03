import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';

class MockNewsApiService extends Mock implements NewsApiService {}

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockNewsApiService mockApiService;
  late MockAppDatabase mockDatabase;
  late ArticleRepositoryImpl repository;

  setUp(() {
    mockApiService = MockNewsApiService();
    mockDatabase = MockAppDatabase();
    repository = ArticleRepositoryImpl(mockApiService, mockDatabase);
  });

  const testModels = [
    ArticleModel(
      author: 'Author',
      title: 'Title',
      description: 'Desc',
      url: 'https://example.com',
      urlToImage: 'https://example.com/img.jpg',
      publishedAt: '2024-01-01',
      content: 'Content',
    ),
  ];

  group('ArticleRepositoryImpl.getNewsArticles', () {
    test('returns DataSuccess when API responds with 200', () async {
      final response = Response<List<ArticleModel>>(
        requestOptions: RequestOptions(path: '/top-headlines'),
        statusCode: 200,
        data: testModels,
      );
      final httpResponse = HttpResponse<List<ArticleModel>>(testModels, response);

      when(() => mockApiService.getNewsArticles(
            apiKey: any(named: 'apiKey'),
            country: any(named: 'country'),
            category: any(named: 'category'),
          )).thenAnswer((_) async => httpResponse);

      final result = await repository.getNewsArticles();

      expect(result, isA<DataSuccess<List<ArticleModel>>>());
      expect(result.data, equals(testModels));
    });

    test('returns DataFailed with NetworkException when DioError is thrown', () async {
      final dioError = DioError(
        requestOptions: RequestOptions(path: '/top-headlines'),
        type: DioErrorType.other,
        error: 'connection refused',
      );

      when(() => mockApiService.getNewsArticles(
            apiKey: any(named: 'apiKey'),
            country: any(named: 'country'),
            category: any(named: 'category'),
          )).thenThrow(dioError);

      final result = await repository.getNewsArticles();

      expect(result, isA<DataFailed<List<ArticleModel>>>());
      expect(result.error, isA<NetworkException>());
    });
  });
}
