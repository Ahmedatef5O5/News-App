import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/router/app_router.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/services/local_database_hive.dart';
import 'package:news_app/core/utilities/constants/app_constants.dart';
import 'package:news_app/core/utilities/theme/app_theme.dart';
import 'package:news_app/features/favorites/favorite_cubit/favorite_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabaseHive.initHive();
  runApp(
    BlocProvider(create: (context) => FavoriteCubit(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.maintheme,
      // home: HomeView(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.homeView,
    );
  }
}
