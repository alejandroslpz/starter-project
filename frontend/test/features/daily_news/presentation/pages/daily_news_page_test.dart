import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';

// Mock BLoC — bloc_test + mocktail pattern (matches project conventions).
class MockRemoteArticlesBloc
    extends MockBloc<RemoteArticlesEvent, RemoteArticlesState>
    implements RemoteArticlesBloc {}

// Stub widget used as the /SavedArticles route destination so we can verify
// navigation without pulling in the full DI-wired SavedArticles screen.
class _SavedArticlesStub extends StatelessWidget {
  const _SavedArticlesStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('SavedArticles')),
    );
  }
}

// Minimal article with all non-nullable fields populated.
// ArticleWidget uses `article!.urlToImage!` and `article!.publishedAt!`
// directly, so both must be non-null to avoid a runtime null-check failure
// during widget rendering.
const _mockArticle = ArticleEntity(
  id: 1,
  author: 'Test Author',
  title: 'Test Article Title',
  description: 'Test article description text.',
  url: 'https://example.com/article',
  urlToImage: 'https://example.com/image.jpg',
  publishedAt: '2026-05-02',
  content: 'Full content of the test article.',
);

Widget _buildTestWidget(RemoteArticlesBloc bloc) {
  return BlocProvider<RemoteArticlesBloc>.value(
    value: bloc,
    child: MaterialApp(
      routes: {
        '/SavedArticles': (_) => const _SavedArticlesStub(),
      },
      home: const DailyNews(),
    ),
  );
}

void main() {
  late MockRemoteArticlesBloc bloc;

  setUp(() {
    bloc = MockRemoteArticlesBloc();
  });

  tearDown(() {
    bloc.close();
  });

  // R15 — Scenario 6: regression tests for DailyNews feed behaviour.

  group('DailyNews page — R15 regression', () {
    testWidgets(
        'shows CupertinoActivityIndicator when BLoC emits RemoteArticlesLoading',
        (tester) async {
      when(() => bloc.state).thenReturn(const RemoteArticlesLoading());

      await tester.pumpWidget(_buildTestWidget(bloc));
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets(
        'shows article tile when BLoC emits RemoteArticlesDone with one article',
        (tester) async {
      when(() => bloc.state)
          .thenReturn(const RemoteArticlesDone([_mockArticle]));

      await tester.pumpWidget(_buildTestWidget(bloc));
      // Allow image network fetch to settle (cached_network_image)
      await tester.pump();

      // The article title appears in the rendered list.
      expect(find.text('Test Article Title'), findsOneWidget);
    });

    testWidgets(
        'shows refresh icon when BLoC emits RemoteArticlesError',
        (tester) async {
      when(() => bloc.state).thenReturn(
          const RemoteArticlesError(NetworkException(message: 'no network')));

      await tester.pumpWidget(_buildTestWidget(bloc));
      await tester.pump();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets(
        'tapping bookmark icon in AppBar navigates to /SavedArticles',
        (tester) async {
      when(() => bloc.state)
          .thenReturn(const RemoteArticlesDone([_mockArticle]));

      await tester.pumpWidget(_buildTestWidget(bloc));
      await tester.pump();

      // The bookmark icon is rendered inside GestureDetector in the AppBar.
      final bookmarkIcon = find.byIcon(Icons.bookmark);
      expect(bookmarkIcon, findsOneWidget);

      await tester.tap(bookmarkIcon);
      await tester.pumpAndSettle();

      // After navigation the stub screen is visible.
      expect(find.text('SavedArticles'), findsOneWidget);
    });
  });
}
