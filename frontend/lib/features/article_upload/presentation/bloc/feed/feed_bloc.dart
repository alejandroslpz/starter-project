import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_community_feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/page_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_fitness_articles.dart';
import 'feed_event.dart';
import 'feed_state.dart';

const int _kPageSize = 20;
const int _kCommunityPageSize = 20;

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetArticleUseCase _getNewsArticles;
  final GetFitnessArticlesUseCase _getFitnessArticles;
  final WatchCommunityFeedUseCase _watchCommunityFeed;

  StreamSubscription<List<JournalistArticleEntity>>? _communitySub;

  FeedBloc(
    this._getNewsArticles,
    this._getFitnessArticles,
    this._watchCommunityFeed,
  ) : super(const FeedState()) {
    on<LoadFeedEvent>(_onLoad);
    on<LoadMoreEvent>(_onLoadMore);
    on<FilterChangedEvent>((e, emit) => emit(state.copyWith(filter: e.filter)));
    on<SearchQueryChangedEvent>(
        (e, emit) => emit(state.copyWith(searchQuery: e.query)));
    on<NewsFeedUpdatedEvent>(
        (e, emit) => emit(state.copyWith(newsArticles: e.articles)));
    on<NewsFeedAppendedEvent>((e, emit) {
      final merged = [...state.rawNewsArticles, ...e.articles];
      emit(state.copyWith(newsArticles: merged));
    });
    on<FitnessFeedUpdatedEvent>(
        (e, emit) => emit(state.copyWith(fitnessArticles: e.articles)));
    on<FitnessFeedAppendedEvent>((e, emit) {
      final merged = [...state.rawFitnessArticles, ...e.articles];
      emit(state.copyWith(fitnessArticles: merged));
    });
    on<CommunityFeedUpdatedEvent>(
        (e, emit) => emit(state.copyWith(communityArticles: e.articles)));
    on<CommunityFeedFailedEvent>(
        (e, emit) => emit(state.copyWith(error: e.error)));
  }

  Future<void> _onLoad(
    LoadFeedEvent event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      newsPage: 1,
      fitnessPage: 1,
      communityLimit: _kCommunityPageSize,
      hasMoreNews: true,
      hasMoreFitness: true,
    ));

    final results = await Future.wait([
      _getNewsArticles.call(
          params: const PageParams(page: 1, pageSize: _kPageSize)),
      _getFitnessArticles.call(
          params: const PageParams(page: 1, pageSize: _kPageSize)),
    ]);
    final newsResult = results[0];
    final fitnessResult = results[1];
    if (newsResult is DataSuccess<List<ArticleEntity>>) {
      final raw = newsResult.data ?? const <ArticleEntity>[];
      add(NewsFeedUpdatedEvent(_filterComplete(raw)));
      if (raw.length < _kPageSize) {
        emit(state.copyWith(hasMoreNews: false));
      }
    }
    if (fitnessResult is DataSuccess<List<ArticleEntity>>) {
      final raw = fitnessResult.data ?? const <ArticleEntity>[];
      add(FitnessFeedUpdatedEvent(_filterComplete(raw)));
      if (raw.length < _kPageSize) {
        emit(state.copyWith(hasMoreFitness: false));
      }
    }

    emit(state.copyWith(isLoading: false));

    _communitySub?.cancel();
    _communitySub =
        _watchCommunityFeed.call(params: state.communityLimit).listen(
      (articles) => add(CommunityFeedUpdatedEvent(articles)),
      onError: (Object e, StackTrace st) =>
          add(CommunityFeedFailedEvent(_mapStreamError(e, st))),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true, error: null));

    switch (state.filter) {
      case FeedFilter.news:
        await _loadMoreNews(emit);
      case FeedFilter.fitnessNews:
        await _loadMoreFitness(emit);
      case FeedFilter.community:
        _bumpCommunityLimit(emit);
      case FeedFilter.all:
        await Future.wait([
          if (state.hasMoreNews) _loadMoreNews(emit),
          if (state.hasMoreFitness) _loadMoreFitness(emit),
        ]);
        _bumpCommunityLimit(emit);
    }

    emit(state.copyWith(isLoadingMore: false));
  }

  Future<void> _loadMoreNews(Emitter<FeedState> emit) async {
    if (!state.hasMoreNews) return;
    final nextPage = state.newsPage + 1;
    final result = await _getNewsArticles.call(
      params: PageParams(page: nextPage, pageSize: _kPageSize),
    );
    if (result is DataSuccess<List<ArticleEntity>>) {
      final raw = result.data ?? const <ArticleEntity>[];
      add(NewsFeedAppendedEvent(_filterComplete(raw)));
      emit(state.copyWith(
        newsPage: nextPage,
        hasMoreNews: raw.length >= _kPageSize,
      ));
    }
  }

  Future<void> _loadMoreFitness(Emitter<FeedState> emit) async {
    if (!state.hasMoreFitness) return;
    final nextPage = state.fitnessPage + 1;
    final result = await _getFitnessArticles.call(
      params: PageParams(page: nextPage, pageSize: _kPageSize),
    );
    if (result is DataSuccess<List<ArticleEntity>>) {
      final raw = result.data ?? const <ArticleEntity>[];
      add(FitnessFeedAppendedEvent(_filterComplete(raw)));
      emit(state.copyWith(
        fitnessPage: nextPage,
        hasMoreFitness: raw.length >= _kPageSize,
      ));
    }
  }

  void _bumpCommunityLimit(Emitter<FeedState> emit) {
    final newLimit = state.communityLimit + _kCommunityPageSize;
    emit(state.copyWith(communityLimit: newLimit));
    _communitySub?.cancel();
    _communitySub = _watchCommunityFeed.call(params: newLimit).listen(
      (articles) => add(CommunityFeedUpdatedEvent(articles)),
      onError: (Object e, StackTrace st) =>
          add(CommunityFeedFailedEvent(_mapStreamError(e, st))),
    );
  }

  /// Drops NewsAPI articles that are unsafe to render: missing or "[Removed]"
  /// title/content, or a thumbnail URL that isn't a syntactically valid http(s)
  /// link. Broken images that are syntactically valid still fall through and
  /// are handled by `Image.network`'s `errorBuilder` at render time.
  List<ArticleEntity> _filterComplete(List<ArticleEntity> articles) {
    return articles.where(_isCompleteNewsArticle).toList();
  }

  static bool _isCompleteNewsArticle(ArticleEntity a) {
    final title = a.title;
    if (title == null || title.isEmpty || title == '[Removed]') return false;
    final description = a.description;
    if (description == null || description.isEmpty) return false;
    final url = a.urlToImage;
    if (url == null || url.isEmpty) return false;
    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasScheme) return false;
    if (parsed.scheme != 'http' && parsed.scheme != 'https') return false;
    return true;
  }

  AppException _mapStreamError(Object e, StackTrace st) {
    if (e is AppException) return e;
    return FirestoreException(
      message: e.toString(),
      cause: e,
      stackTrace: st,
    );
  }

  @override
  Future<void> close() {
    _communitySub?.cancel();
    return super.close();
  }
}
