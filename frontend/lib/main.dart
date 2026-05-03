import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'config/theme/app_themes.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  assert(
    newsAPIKey.isNotEmpty,
    'NEWS_API_KEY is empty. Pass --dart-define=NEWS_API_KEY=<key>. '
    'See frontend/README.md for instructions.',
  );

  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthBloc as lazySingleton — wraps the entire app so every route shares
    // the same auth state (design D12, R18).
    // Dispatches WatchAuthState immediately so anonymous bootstrap starts
    // before the first frame (design D10, SD1).
    final authBloc = sl<AuthBloc>()..add(WatchAuthStateEvent());

    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: BlocProvider<RemoteArticlesBloc>(
        create: (context) => sl()..add(const GetArticles()),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: theme(),
          routerConfig: AppRouter.create(authBloc),
        ),
      ),
    );
  }
}
