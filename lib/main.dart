import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:news_app/core/cubits/category_cubit.dart';
import 'package:news_app/core/locale/locale_cubit.dart';
import 'package:news_app/core/network/connectivity_cubit.dart';
import 'package:news_app/core/router/app_router.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/secrets/app_secrets.dart';
import 'package:news_app/core/services/local_database_hive.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/di/service_locator.dart';
import 'package:news_app/core/theme/app_theme.dart';
import 'package:news_app/features/auth/cubit/auth_cubit.dart';
import 'package:news_app/features/auth/cubit/auth_listener_cubit.dart';
import 'package:news_app/features/favorites/cubit/favorite_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/model/theme_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  await LocalDatabaseHive.initHive();

  // Register all dependencies before the widget tree is built.
  await setupServiceLocator();

  runApp(
    const NewsWave(),
  );
}

class NewsWave extends StatelessWidget {
  const NewsWave({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ── Singletons pulled directly from the service locator ──────────
        BlocProvider<ConnectivityCubit>(
          create: (_) => sl<ConnectivityCubit>(),
        ),

        BlocProvider<AuthListenerCubit>(create: (_) => sl<AuthListenerCubit>()),

        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>()..init(),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => sl<ThemeCubit>()..init(),
        ),

        BlocProvider<LocaleCubit>(
          create: (_) => sl<LocaleCubit>()..init(),
        ),
        BlocProvider<FavoritesCubit>(
          create: (context) => sl<FavoritesCubit>(),
        ),
        BlocProvider<CategoryCubit>(
          create: (context) => sl<CategoryCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            buildWhen: (previous, current) =>
                previous.languageCode != current.languageCode,
            builder: (context, locale) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                title: AppConstants.appName,
                // ── Localisation ────────────────────────────────────────────
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: AppTheme.of(
                  locale: locale,
                  brightness: Brightness.light,
                ),
                darkTheme: AppTheme.of(
                  locale: locale,
                  brightness: Brightness.dark,
                ),
                themeMode: themeMode,
                onGenerateRoute: AppRouter.onGenerateRoute,
                initialRoute: AppRoutes.splashRoute,

                // builder: DevicePreview.appBuilder,
              );
            },
          );
        },
      ),
    );
  }
}
