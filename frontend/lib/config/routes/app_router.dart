import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/my_articles/my_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/pages/article_edit/article_edit_page.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/pages/article_upload/article_upload_page.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/pages/my_articles/my_articles_page.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/login/login_page.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/signup/signup_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/saved_article/saved_article.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

/// Creates and configures the app-wide [GoRouter].
///
/// Route table:
///   /               → DailyNews
///   /article/upload → ArticleUploadPage (auth-required)
///   /article/edit/:id → ArticleEditPage (auth-required)
///   /my-articles    → MyArticlesPage (auth-required)
///   /article/:id    → ArticleDetails
///   /saved          → SavedArticles
///   /login          → LoginPage
///   /signup         → SignupPage
class AppRouter {
  const AppRouter._();

  /// Factory method that wires [AuthBloc] to [GoRouterRefreshStream].
  static GoRouter create(AuthBloc authBloc) {
    String? requireAuth(GoRouterState state) {
      if (authBloc.state is AuthAuthenticated) return null;
      final returnTo = Uri.encodeComponent(state.uri.toString());
      return '/login?return=$returnTo';
    }

    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final loc = state.matchedLocation;
        // Once authenticated, /login and /signup are no-ops — bounce home.
        if (authState is AuthAuthenticated &&
            (loc == '/login' || loc == '/signup')) {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DailyNews(),
        ),
        GoRoute(
          path: '/article/upload',
          redirect: (context, state) => requireAuth(state),
          builder: (context, state) {
            final draftIdRaw = state.uri.queryParameters['draftId'];
            final draftId = draftIdRaw == null ? null : int.tryParse(draftIdRaw);
            return BlocProvider<UploadArticleBloc>(
              create: (_) {
                final bloc = sl<UploadArticleBloc>();
                if (draftId != null) {
                  bloc.add(LoadDraftEvent(draftId));
                }
                return bloc;
              },
              child: const ArticleUploadPage(),
            );
          },
        ),
        GoRoute(
          path: '/article/edit/:id',
          redirect: (context, state) => requireAuth(state),
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BlocProvider<UploadArticleBloc>(
              create: (_) => sl<UploadArticleBloc>(),
              child: ArticleEditPage(articleId: id),
            );
          },
        ),
        GoRoute(
          path: '/my-articles',
          redirect: (context, state) => requireAuth(state),
          builder: (context, state) {
            final uid =
                (authBloc.state as AuthAuthenticated).user.uid;
            return BlocProvider<MyArticlesBloc>(
              create: (_) => sl<MyArticlesBloc>(),
              child: MyArticlesPage(userId: uid),
            );
          },
        ),
        GoRoute(
          path: '/article/:id',
          builder: (context, state) {
            final article = state.extra as ArticleEntity?;
            if (article != null) {
              return ArticleDetailsView(article: article);
            }
            final id = state.pathParameters['id']!;
            return ArticleDetailsView(communityArticleId: id);
          },
        ),
        GoRoute(
          path: '/saved',
          builder: (context, state) => const SavedArticles(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupPage(),
        ),
      ],
    );
  }
}

/// Bridges a [Stream] to the [ChangeNotifier] interface expected by
/// [GoRouter.refreshListenable].
///
/// Subscribes to [stream] in the constructor, calls [notifyListeners]
/// on each emission, and cancels the subscription in [dispose].
class GoRouterRefreshStream extends ChangeNotifier {
  StreamSubscription<dynamic>? _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
