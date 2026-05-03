import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/login/login_page.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/signup/signup_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/saved_article/saved_article.dart';

/// Creates and configures the app-wide [GoRouter] (design D7).
///
/// Route table (6 routes):
///   /               → DailyNews
///   /article/:id    → ArticleDetails
///   /saved          → SavedArticles
///   /login          → LoginPage
///   /signup         → SignupPage
///   /article/upload → placeholder (article-upload change adds UI)
///
/// [redirect] returns null for all routes in v1 — no route guarding yet.
/// The `article-upload` change adds the guard on `/article/upload`.
class AppRouter {
  const AppRouter._();

  /// Factory method that wires [AuthBloc] to [GoRouterRefreshStream].
  static GoRouter create(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      // redirect: returns null for all routes in v1 (design D7)
      redirect: (context, state) => null,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DailyNews(),
        ),
        GoRoute(
          path: '/article/upload',
          builder: (context, state) => const _PlaceholderScreen(
            'Article upload coming soon',
          ),
        ),
        GoRoute(
          path: '/article/:id',
          builder: (context, state) {
            final article = state.extra as ArticleEntity?;
            return ArticleDetailsView(article: article);
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
/// [GoRouter.refreshListenable] (design D9).
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

/// Placeholder screen for routes whose UI has not landed yet.
class _PlaceholderScreen extends StatelessWidget {
  final String message;
  const _PlaceholderScreen(this.message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(message)),
    );
  }
}
