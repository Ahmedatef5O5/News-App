import 'package:flutter/material.dart';
import 'package:news_app/core/router/app_router.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/utilities/constants/app_constants.dart';
import 'package:news_app/core/utilities/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
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
      initialRoute: AppRoutes.home,
    );
  }
}
