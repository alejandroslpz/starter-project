import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Daily News',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        const _AccountAction(),
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.bookmark, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildPage() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: const Center(child: CupertinoActivityIndicator()));
        }
        if (state is RemoteArticlesError) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: const Center(child: Icon(Icons.refresh)));
        }
        if (state is RemoteArticlesDone) {
          return _buildArticlesPage(context, state.articles!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    List<Widget> articleWidgets = [];
    for (var article in articles) {
      articleWidgets.add(ArticleWidget(
        article: article,
        onArticlePressed: (article) => _onArticlePressed(context, article),
      ));
    }

    return Scaffold(
      appBar: _buildAppbar(context),
      body: ListView(
        children: articleWidgets,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: REPLACE ROUTE WITH YOUR "ADD ARTICLE" PAGE
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    final id = Uri.encodeComponent(article.url ?? 'unknown');
    context.push('/article/$id', extra: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    context.push('/saved');
  }
}

/// AppBar action that surfaces the current auth state.
///
/// - When the user is anonymous (or no user yet), shows a `person_outline` icon
///   that navigates to `/login` on tap — entry point to email/password and
///   Google sign-in flows.
/// - When authenticated, shows a filled `account_circle` icon that opens a
///   menu with the user's display name/email plus a sign-out action.
class _AccountAction extends StatelessWidget {
  const _AccountAction();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return _AuthenticatedMenu(state: state);
        }
        return GestureDetector(
          onTap: () => context.push('/login'),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.person_outline, color: Colors.black),
          ),
        );
      },
    );
  }
}

class _AuthenticatedMenu extends StatelessWidget {
  final AuthAuthenticated state;
  const _AuthenticatedMenu({required this.state});

  @override
  Widget build(BuildContext context) {
    final label = state.user.displayName ?? state.user.email ?? 'Account';
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle, color: Colors.black),
      onSelected: (value) {
        if (value == 'signout') {
          context.read<AuthBloc>().add(SignOutEvent());
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'signout',
          child: Text('Sign out'),
        ),
      ],
    );
  }
}
