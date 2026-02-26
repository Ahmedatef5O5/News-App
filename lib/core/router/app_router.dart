import 'package:flutter/material.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/features/Home/views/article_details_view.dart';
import 'package:news_app/features/Home/views/home_view.dart';
import 'package:news_app/features/search/views/search_view.dart';
import '../models/news_api_response.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.homeView:
        return MaterialPageRoute(
          builder: (BuildContext context) => HomeView(),
          settings: settings,
        );
      case AppRoutes.searchView:
        // final article = settings.arguments as Article;
        return MaterialPageRoute(
          builder: (BuildContext context) => SearchView(),
          settings: settings,
        );
      case AppRoutes.artcileDetailsView:
        final article = settings.arguments as Article;
        return MaterialPageRoute(
          builder: (BuildContext context) =>
              ArticleDetailsView(article: article),
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
