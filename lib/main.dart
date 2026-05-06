import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_app/core/cubits/category_cubit.dart';
import 'package:news_app/core/router/app_router.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/secrets/app_secrets.dart';
import 'package:news_app/core/services/local_database_hive.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/theme/app_theme.dart';
import 'package:news_app/features/auth/cubit/auth_cubit.dart';
import 'package:news_app/features/favorites/favorite_cubit/favorite_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/model/theme_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  await LocalDatabaseHive.initHive();

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;

    if (event == AuthChangeEvent.passwordRecovery) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.upadatePasswordRoute,
        (route) => false,
      );
    }
  });

  runApp(
    DevicePreview(
        enabled: !kReleaseMode, builder: (context) => const NewsWave()),
  );
}

class NewsWave extends StatelessWidget {
  const NewsWave({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit()..init(),
        ),
        BlocProvider(
          create: (_) => ThemeCubit()..init(),
        ),
        BlocProvider(
          create: (context) => FavoritesCubit(),
        ),
        BlocProvider(
          create: (context) => CategoryCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRoutes.signInRoute,
          );
        },
      ),
    );
  }
}
