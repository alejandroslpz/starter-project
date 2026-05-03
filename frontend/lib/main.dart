import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/bootstrap_auth.dart';
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

  // One-shot auth bootstrap, BEFORE runApp:
  //   - validates the locally-cached user against the server (recovers from
  //     dev workflows that wipe Firebase data),
  //   - signs in anonymously if no valid user remains.
  // Centralising this here is the canonical FlutterFire pattern; doing it
  // inside the bloc would let widget rebuilds re-trigger sign-in and create
  // duplicate anonymous users (FlutterFire #3053).
  try {
    await sl<BootstrapAuthUseCase>().call(params: const NoParams());
  } catch (e) {
    // Swallow: app still boots into AuthUnauthenticated and the user can
    // sign in via /login. Common cause: Anonymous provider disabled in
    // Firebase Console or device offline.
    debugPrint('Auth bootstrap failed: $e');
  }

  runApp(const MyApp());
}

/// App root widget.
///
/// Owns the lifecycle of the app-wide [AuthBloc]: dispatches
/// [WatchAuthStateEvent] **once** in [initState] and reuses the same
/// [GoRouter] across rebuilds. Doing this in [build] would re-issue the
/// event on every rebuild and spawn duplicate stream subscriptions.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _authBloc.add(WatchAuthStateEvent());
    _router = AppRouter.create(_authBloc);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: BlocProvider<RemoteArticlesBloc>(
        create: (context) => sl()..add(const GetArticles()),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: theme(),
          routerConfig: _router,
        ),
      ),
    );
  }
}
