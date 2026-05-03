import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class MockNewsApiService extends Mock implements NewsApiService {}

class MockArticleDao extends Mock implements ArticleDao {}

class FakeArticleModel extends Fake implements ArticleModel {}

class MockAppDatabase extends Mock implements AppDatabase {
  final ArticleDao _dao;
  MockAppDatabase(this._dao);

  @override
  ArticleDao get articleDAO => _dao;
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeArticleModel());
  });

  late MockNewsApiService mockApiService;
  late MockArticleDao mockDao;
  late MockAppDatabase mockDatabase;
  late ArticleRepositoryImpl repository;

  setUp(() {
    mockApiService = MockNewsApiService();
    mockDao = MockArticleDao();
    mockDatabase = MockAppDatabase(mockDao);
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
    test('returns DataSuccess with entities on 200', () async {
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

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, isA<List<ArticleEntity>>());
      expect(result.data, hasLength(testModels.length));
      expect(result.data!.first.title, equals(testModels.first.title));
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

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, isA<NetworkException>());
    });

    test('returns DataFailed with NetworkException when HTTP status is not 200',
        () async {
      final response = Response<List<ArticleModel>>(
        requestOptions: RequestOptions(path: '/top-headlines'),
        statusCode: 500,
        statusMessage: 'Internal Server Error',
        data: null,
      );
      final httpResponse =
          HttpResponse<List<ArticleModel>>(testModels, response);

      when(() => mockApiService.getNewsArticles(
            apiKey: any(named: 'apiKey'),
            country: any(named: 'country'),
            category: any(named: 'category'),
          )).thenAnswer((_) async => httpResponse);

      final result = await repository.getNewsArticles();

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, isA<NetworkException>());
      expect(result.error?.code, equals('500'));
    });

    test('returns DataFailed with UnknownException when unexpected error occurs',
        () async {
      when(() => mockApiService.getNewsArticles(
            apiKey: any(named: 'apiKey'),
            country: any(named: 'country'),
            category: any(named: 'category'),
          )).thenThrow(Exception('unexpected'));

      final result = await repository.getNewsArticles();

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, isA<UnknownException>());
    });
  });

  group('ArticleRepositoryImpl local CRUD', () {
    test('getSavedArticles returns entities from DAO', () async {
      when(() => mockDao.getArticles()).thenAnswer((_) async => testModels);

      final result = await repository.getSavedArticles();

      expect(result, isA<List<ArticleEntity>>());
      expect(result, hasLength(testModels.length));
      expect(result.first.title, equals(testModels.first.title));
      verify(() => mockDao.getArticles()).called(1);
    });

    test('saveArticle delegates to articleDAO.insertArticle', () async {
      const entity = ArticleEntity(
        id: 1,
        author: 'Author',
        title: 'Title',
        description: 'Desc',
        url: 'https://example.com',
        urlToImage: 'https://example.com/img.jpg',
        publishedAt: '2024-01-01',
        content: 'Content',
      );
      when(() => mockDao.insertArticle(any())).thenAnswer((_) async {});

      await repository.saveArticle(entity);

      verify(() => mockDao.insertArticle(any())).called(1);
    });

    test('removeArticle delegates to articleDAO.deleteArticle', () async {
      const entity = ArticleEntity(
        id: 1,
        author: 'Author',
        title: 'Title',
        description: 'Desc',
        url: 'https://example.com',
        urlToImage: 'https://example.com/img.jpg',
        publishedAt: '2024-01-01',
        content: 'Content',
      );
      when(() => mockDao.deleteArticle(any())).thenAnswer((_) async {});

      await repository.removeArticle(entity);

      verify(() => mockDao.deleteArticle(any())).called(1);
    });
  });
}
