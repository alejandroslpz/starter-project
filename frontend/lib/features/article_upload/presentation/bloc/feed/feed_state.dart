import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/feed/domain/entities/feed_item.dart';

enum FeedFilter { all, fitnessNews, news, community }

final class FeedState extends Equatable {
  final List<ArticleEntity> _newsArticles;
  final List<ArticleEntity> _fitnessArticles;
  final List<JournalistArticleEntity> _communityArticles;
  final FeedFilter filter;
  final String searchQuery;
  final bool isLoading;
  final bool isLoadingMore;
  final int newsPage;
  final int fitnessPage;
  final int communityLimit;
  final bool hasMoreNews;
  final bool hasMoreFitness;
  final AppException? error;

  const FeedState({
    List<ArticleEntity> newsArticles = const [],
    List<ArticleEntity> fitnessArticles = const [],
    List<JournalistArticleEntity> communityArticles = const [],
    this.filter = FeedFilter.all,
    this.searchQuery = '',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.newsPage = 1,
    this.fitnessPage = 1,
    this.communityLimit = 20,
    this.hasMoreNews = true,
    this.hasMoreFitness = true,
    this.error,
  })  : _newsArticles = newsArticles,
        _fitnessArticles = fitnessArticles,
        _communityArticles = communityArticles;

  /// Read-only access to the raw news list for pagination append operations.
  List<ArticleEntity> get rawNewsArticles => List.unmodifiable(_newsArticles);

  /// Read-only access to the raw fitness list for pagination append operations.
  List<ArticleEntity> get rawFitnessArticles =>
      List.unmodifiable(_fitnessArticles);

  List<FeedItem> get items {
    final filtered = <FeedItem>[];

    switch (filter) {
      case FeedFilter.all:
        filtered.addAll(_fitnessArticles.map(NewsApiFeedItem.new));
        filtered.addAll(_newsArticles.map(NewsApiFeedItem.new));
        filtered.addAll(_communityArticles.map(JournalistFeedItem.new));
      case FeedFilter.fitnessNews:
        filtered.addAll(_fitnessArticles.map(NewsApiFeedItem.new));
      case FeedFilter.news:
        filtered.addAll(_newsArticles.map(NewsApiFeedItem.new));
      case FeedFilter.community:
        filtered.addAll(_communityArticles.map(JournalistFeedItem.new));
    }

    filtered.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    if (searchQuery.isEmpty) return filtered;
    final q = searchQuery.toLowerCase();
    return filtered.where((i) => i.title.toLowerCase().contains(q)).toList();
  }

  FeedState copyWith({
    List<ArticleEntity>? newsArticles,
    List<ArticleEntity>? fitnessArticles,
    List<JournalistArticleEntity>? communityArticles,
    FeedFilter? filter,
    String? searchQuery,
    bool? isLoading,
    bool? isLoadingMore,
    int? newsPage,
    int? fitnessPage,
    int? communityLimit,
    bool? hasMoreNews,
    bool? hasMoreFitness,
    Object? error = _sentinel,
  }) {
    return FeedState(
      newsArticles: newsArticles ?? _newsArticles,
      fitnessArticles: fitnessArticles ?? _fitnessArticles,
      communityArticles: communityArticles ?? _communityArticles,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      newsPage: newsPage ?? this.newsPage,
      fitnessPage: fitnessPage ?? this.fitnessPage,
      communityLimit: communityLimit ?? this.communityLimit,
      hasMoreNews: hasMoreNews ?? this.hasMoreNews,
      hasMoreFitness: hasMoreFitness ?? this.hasMoreFitness,
      error: error == _sentinel ? this.error : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [
        _newsArticles,
        _fitnessArticles,
        _communityArticles,
        filter,
        searchQuery,
        isLoading,
        isLoadingMore,
        newsPage,
        fitnessPage,
        communityLimit,
        hasMoreNews,
        hasMoreFitness,
        error,
      ];
}

const _sentinel = Object();
