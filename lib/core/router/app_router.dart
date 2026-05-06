import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/features/Home/views/home_view.dart';
import 'package:news_app/features/auth/views/forgot_password_view.dart';
import 'package:news_app/features/auth/views/onboarding_view.dart';
import 'package:news_app/features/auth/views/sign_in_view.dart';
import 'package:news_app/features/favorites/views/favorites_view.dart';
import 'package:news_app/features/profile/views/profile_settings_view.dart';
import 'package:news_app/features/search/Search_cubit/search_cubit.dart';
import 'package:news_app/features/search/views/search_view.dart';
import '../../features/Headlines/views/headlines_view.dart';
import '../../features/Home/views/article_details_view.dart';
import '../../features/auth/views/sign_up_view.dart';
import '../../features/auth/views/update_password_view.dart';
import '../models/article_model.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    String routeName = settings.name ?? '';
    if (routeName.contains('?')) {
      routeName = routeName.split('?').first;
    }

    if (routeName.isEmpty || routeName == '/') {
      routeName = AppRoutes.signInRoute;
    }
    // switch (settings.name)
    switch (routeName) {
      case AppRoutes.signInRoute:
        return _fadeRoute(
          SignInView(),
          settings,
        );
      case AppRoutes.signUpRoute:
        return _fadeRoute(
          SignUpView(),
          settings,
        );
      case AppRoutes.forgotPasswordRoute:
        return _fadeRoute(
          ForgotPasswordView(),
          settings,
        );
      case AppRoutes.upadatePasswordRoute:
        return _fadeRoute(
          const UpdatePasswordView(), // الشاشة اللي هتصممها
          settings,
        );
      case AppRoutes.onboardingRoute:
        return _fadeRoute(
          OnboardingView(),
          settings,
        );
      case AppRoutes.profileSettingsRoute:
        return _fadeRoute(
          ProfileSettingsView(),
          settings,
        );

      //
      case AppRoutes.homeRoute:
        return _fadeRoute(
          HomeView(),
          settings,
        );

      case AppRoutes.searchRoute:
        return _slideRoute(
          BlocProvider(
            create: (_) => SearchCubit(),
            child: SearchView(),
          ),
          settings,
        );
      case AppRoutes.favoriteRoute:
        return _slideRoute(
          FavoritesView(),
          settings,
        );
      case AppRoutes.headlinesRoute:
        return _slideRoute(
          const HeadlinesView(),
          settings,
        );

      case AppRoutes.artcileDetailsRoute:
        final article = settings.arguments as Article;
        return _sharedAxisRoute(
          ArticleDetailView(article: article),
          settings,
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static Route<dynamic> _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  static Route<dynamic> _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
    );
  }

  static Route<dynamic> _sharedAxisRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 380),
    );
  }
}
