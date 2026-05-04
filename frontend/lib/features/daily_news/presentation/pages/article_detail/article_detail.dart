import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_article_by_id.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;
  final JournalistArticleEntity? communityArticle;
  final String? communityArticleId;

  const ArticleDetailsView({
    super.key,
    this.article,
    this.communityArticle,
    this.communityArticleId,
  });

  @override
  Widget build(BuildContext context) {
    if (communityArticle != null) {
      return _CommunityArticleDetail(article: communityArticle!);
    }
    if (communityArticleId != null) {
      return _CommunityArticleByIdLoader(articleId: communityArticleId!);
    }
    if (article == null) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context).articleDetailNotFound),
        ),
      );
    }
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBackButtonTapped(context),
          child: const Icon(Ionicons.chevron_back, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildArticleTitleAndDate(),
          _buildArticleImage(),
          _buildArticleDescription(),
        ],
      ),
    );
  }

  Widget _buildArticleTitleAndDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article!.title!,
            style: const TextStyle(
                fontFamily: 'Butler',
                fontSize: 20,
                fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Ionicons.time_outline, size: 16),
              const SizedBox(width: 4),
              Text(
                _formatPublishedAt(article!.publishedAt),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleImage() {
    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      child: Image.network(article!.urlToImage!, fit: BoxFit.cover),
    );
  }

  Widget _buildArticleDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Text(
        '${article!.description ?? ''}\n\n${article!.content ?? ''}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () => _onFloatingActionButtonPressed(context),
        child: const Icon(Ionicons.bookmark, color: Colors.white),
      ),
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  void _onFloatingActionButtonPressed(BuildContext context) {
    BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(article!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(AppLocalizations.of(context).articleSavedSuccess),
      ),
    );
  }

  static final _dateFormat = DateFormat('MMM d, y · h:mm a');

  static String _formatPublishedAt(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return _dateFormat.format(parsed.toLocal());
  }
}

class _CommunityArticleByIdLoader extends HookWidget {
  final String articleId;

  const _CommunityArticleByIdLoader({required this.articleId});

  @override
  Widget build(BuildContext context) {
    final stream = useMemoized(
      () => sl<WatchArticleByIdUseCase>().call(params: articleId),
      [articleId],
    );
    final snapshot = useStream(stream);

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (snapshot.hasError) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context).articleDetailLoadError),
        ),
      );
    }
    final article = snapshot.data;
    if (article == null) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context).articleDetailNotFound),
        ),
      );
    }
    return _CommunityArticleDetail(article: article);
  }
}

class _CommunityArticleDetail extends StatelessWidget {
  final JournalistArticleEntity article;

  const _CommunityArticleDetail({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: const Icon(Ionicons.chevron_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage.isNotEmpty)
              SizedBox(
                width: double.maxFinite,
                height: 250,
                child: Image.network(article.urlToImage, fit: BoxFit.cover),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontFamily: 'Butler',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.userDisplayName,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Ionicons.time_outline, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, y · h:mm a')
                            .format(article.publishedAt.toLocal()),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${article.description}\n\n${article.content}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
