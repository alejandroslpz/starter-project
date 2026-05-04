import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../shared/feed/domain/entities/feed_item.dart';
import '../../../../../shared/feed/presentation/widgets/feed_item_card.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';

class SavedArticles extends HookWidget {
  const SavedArticles({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBackButtonTapped(context),
          child: const Icon(Ionicons.chevron_back, color: Colors.black),
        ),
      ),
      title: Text(
        AppLocalizations.of(context).savedArticlesTitle,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        if (state is LocalArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (state is LocalArticlesDone) {
          return _SavedArticlesList(articles: state.articles ?? const []);
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }
}

class _SavedArticlesList extends StatelessWidget {
  final List<ArticleEntity> articles;

  const _SavedArticlesList({required this.articles});

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppLocalizations.of(context).savedArticlesEmpty,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: articles.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final article = articles[index];
        final item = NewsApiFeedItem(article);
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: _DismissBackground(
            label: AppLocalizations.of(context).removeAction,
          ),
          onDismissed: (_) => context
              .read<LocalArticleBloc>()
              .add(RemoveArticle(article)),
          child: FeedItemCard(
            item: item,
            onTap: () => _onArticlePressed(context, article),
          ),
        );
      },
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    final id = Uri.encodeComponent(article.url ?? 'unknown');
    context.push('/article/$id', extra: article);
  }
}

class _DismissBackground extends StatelessWidget {
  final String label;
  const _DismissBackground({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.errorContainer,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.delete_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}
