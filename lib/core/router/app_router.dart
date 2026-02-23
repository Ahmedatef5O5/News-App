import 'package:flutter/material.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/features/Home/views/home_view.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (BuildContext context) => HomeView(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
