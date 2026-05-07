import 'package:dio/dio.dart';
import 'package:news_app/core/models/article_model.dart';
import 'package:news_app/core/services/local_database_hive.dart';
import 'package:news_app/features/home/services/home_services.dart';
import '../constants/app_constants.dart';

/// Repository sits between Cubit and Service.
/// Handles caching so the app works offline.

/// Result from a paginated fetch — carries articles AND total count
/// so the Cubit can build the PaginationMeta without knowing about Dio.
class PageResult {
  final List<Article> articles;
  final int totalResults;
  final bool fromCache;

  const PageResult({
    required this.articles,
    required this.totalResults,
    this.fromCache = false,
  });
}

class HomeRepository {
  final HomeServices _services;
  final LocalDatabaseHive _db;

  HomeRepository({HomeServices? services, LocalDatabaseHive? db})
      : _services = services ?? HomeServices(),
        _db = db ?? LocalDatabaseHive.instance;

  Future<List<Article>> getHeadlines({
    String country = 'us',
    String? category,
    int pageSize = AppConstants.headlinesPageSize, // ← NEW PARAM
    bool forceRefresh = false,
  }) async {
    final cacheKey = _headlinesCacheKey(category);

    if (!forceRefresh) {
      final cached = await _getCachedArticles(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final response = await _services.getTopHeadlines(
        country: country,
        category: category,
        pageSize: pageSize,
      );
      await _cacheArticles(cacheKey, response.articles);
      return response.articles;
    } on DioException catch (e) {
      final cached = await _getCachedArticles(cacheKey);
      if (cached != null) return cached;
      throw _mapError(e);
    }
  }

  Future<PageResult> getRecommendedPage({
    String country = 'us',
    required int page,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${AppConstants.recommendedPageKeyPrefix}$page';

    // Try cache first (only on non-forced requests)
    if (!forceRefresh) {
      final cached = await _getCachedPage(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final response = await _services.getRecommended(
        country: country,
        page: page,
      );
      final result = PageResult(
        articles: response.articles,
        totalResults: response.totalResults,
      );
      await _cachePage(cacheKey, result);
      return result;
    } on DioException catch (e) {
      // Offline fallback
      final cached = await _getCachedPage(cacheKey);
      if (cached != null) return cached;
      throw _mapError(e);
    }
  }

  Future<void> clearRecommendedCache() async {
    for (int i = 1; i <= 10; i++) {
      await _db.delete('${AppConstants.recommendedPageKeyPrefix}$i');
    }
  }

  Future<void> _cacheArticles(String key, List<Article> articles) =>
      _db.put(key, articles);

  Future<List<Article>?> _getCachedArticles(String key) async {
    final raw = await _db.get<List<dynamic>>(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return raw.cast<Article>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _cachePage(String key, PageResult result) async {
    // Store articles + totalResults together as a Map
    await _db.put('${key}_articles', result.articles);
    await _db.put('${key}_total', result.totalResults);
  }

  Future<PageResult?> _getCachedPage(String key) async {
    final articles = await _getCachedArticles('${key}_articles');
    final total = await _db.get<int>('${key}_total');
    if (articles == null || total == null) return null;
    return PageResult(
      articles: articles,
      totalResults: total,
      fromCache: true,
    );
  }

  String _headlinesCacheKey(String? category) => category != null
      ? '${AppConstants.cachedHeadlinesKey}_$category'
      : AppConstants.cachedHeadlinesKey;

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'No internet connection. Showing cached news.';
    }
    return e.message ?? 'Something went wrong. Please try again.';
  }
}
