import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_app/core/cubits/category_cubit.dart';
import 'package:news_app/core/router/app_router.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/services/local_database_hive.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/theme/app_theme.dart';
import 'package:news_app/features/favorites/favorite_cubit/favorite_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await LocalDatabaseHive.initHive();
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
          create: (context) => FavoritesCubit(),
        ),
        BlocProvider(
          create: (context) => CategoryCubit(),
        ),
      ],
      child: MaterialApp(
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRoutes.homeRoute,
      ),
    );
  }
}
