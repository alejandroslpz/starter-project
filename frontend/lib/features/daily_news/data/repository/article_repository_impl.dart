import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;

  ArticleRepositoryImpl(this._newsApiService, this._appDatabase);

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final entities =
            httpResponse.data.map((model) => model.toEntity()).toList();
        return DataSuccess(entities);
      } else {
        return DataFailed(NetworkException(
          message: httpResponse.response.statusMessage ?? 'HTTP error',
          code: httpResponse.response.statusCode?.toString(),
        ));
      }
    } on DioError catch (e) {
      return DataFailed(NetworkException(
        message: e.message,
        cause: e,
        code: e.response?.statusCode?.toString(),
      ));
    } on Object catch (e, st) {
      return DataFailed(UnknownException(
        message: 'Unexpected error in getNewsArticles',
        cause: e,
        stackTrace: st,
      ));
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    final models = await _appDatabase.articleDAO.getArticles();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.insertArticle(ArticleModel.fromEntity(article));
  }
}
