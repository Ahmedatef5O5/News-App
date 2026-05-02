import 'package:dio/dio.dart';
import 'package:news_app/core/models/article_model.dart';
import 'package:news_app/core/services/local_database_hive.dart';
import 'package:news_app/features/Home/services/home_services.dart';

import '../constants/app_constants.dart';

/// Repository sits between Cubit and Service.
/// Handles caching so the app works offline.

class HomeRepository {
  final HomeServices _services;
  final LocalDatabaseHive _db;

  HomeRepository({HomeServices? services, LocalDatabaseHive? db})
      : _services = services ?? HomeServices(),
        _db = db ?? LocalDatabaseHive.instance;

  Future<List<Article>> getHeadlines({
    String country = 'us',
    String? category,
    int page = 1,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _getCached(AppConstants.cachedHeadlinesKey);
      if (cached != null) return cached;
    }

    try {
      final response = await _services.getTopHeadlines(
          country: country, category: category, page: page);
      await _cache(AppConstants.cachedHeadlinesKey, response.articles ?? []);
      return response.articles ?? [];
    } on DioException catch (e) {
      // Offline fallback
      final cached = await _getCached(AppConstants.cachedHeadlinesKey);
      if (cached != null) return cached;
      throw _mapError(e);
    }
  }

  Future<List<Article>> getRecommended({
    String country = 'us',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _getCached(AppConstants.cachedRecommendedKey);
      if (cached != null) return cached;
    }

    try {
      final response =
          await _services.getRecommended(country: country, page: page);
      await _cache(AppConstants.cachedRecommendedKey, response.articles ?? []);
      return response.articles ?? [];
    } on DioException catch (e) {
      // Offline fallback
      final cached = await _getCached(AppConstants.cachedRecommendedKey);
      if (cached != null) return cached;
      throw _mapError(e);
    }
  }

  Future<void> _cache(String key, List<Article> articles) =>
      _db.put(key, articles);

  Future<List<Article>?> _getCached(String key) async {
    final raw = await _db.get<List<dynamic>>(key);
    if (raw == null || raw.isEmpty) return null;
    return raw.cast<Article>();
  }

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'No internet connection. Showing cached news.';
    }
    return e.message ?? 'Something went wrong. Please try again.';
  }
}
