import 'package:dio/dio.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/models/article_model.dart';
import 'package:news_app/core/network/network_info.dart';
import 'package:news_app/core/services/local_database_hive.dart';
import 'package:news_app/features/home/services/home_services.dart';

import '../translation/article_translation_repository.dart';

class PageResult {
  const PageResult({
    required this.articles,
    required this.totalResults,
    this.fromCache = false,
  });

  final List<Article> articles;
  final int totalResults;
  final bool fromCache;
}

class HomeRepository {
  HomeRepository({
    required HomeServices services,
    required LocalDatabaseHive db,
    required NetworkInfo networkInfo,
    required ArticleTranslationRepository translationRepo,
  })  : _services = services,
        _db = db,
        _network = networkInfo,
        _translation = translationRepo;

  final HomeServices _services;
  final LocalDatabaseHive _db;
  final NetworkInfo _network;
  final ArticleTranslationRepository _translation;

  // ── Headlines (simple list) ────────────────────────────────────────────────

  Future<List<Article>> getHeadlines({
    String country = 'us',
    String? category,
    int pageSize = AppConstants.headlinesPageSize,
    bool forceRefresh = false,
    String locale = 'en',
  }) async {
    final result = await getHeadlinesWithMeta(
      country: country,
      category: category,
      pageSize: pageSize,
      forceRefresh: forceRefresh,
      locale: locale,
    );
    return result.articles;
  }

  Future<PageResult> getHeadlinesWithMeta({
    String country = 'us',
    String? category,
    int pageSize = AppConstants.headlinesPageSize,
    bool forceRefresh = false,
    String locale = 'en',
  }) async {
    final cacheKey = _headlinesCacheKey(category);

    // Offline — serve cache instantly, skip Dio entirely.
    final online = await _network.isConnected;
    if (!online) {
      final cached = await _getCachedArticles(cacheKey);
      if (cached != null) {
        final localized = await _translation.localizeArticles(
          cached,
          locale: locale,
        );
        return PageResult(
            articles: localized,
            totalResults: localized.length,
            fromCache: true);
      }
      throw _offlineNoCache();
    }

    // Online — try cache first (unless force-refresh requested).
    if (!forceRefresh) {
      final cached = await _getCachedArticles(cacheKey);
      if (cached != null) {
        final localized = await _translation.localizeArticles(
          cached,
          locale: locale,
        );
        return PageResult(articles: localized, totalResults: localized.length);
      }
    }

    // Network call.
    try {
      final response = await _services.getTopHeadlines(
        country: country,
        category: category,
        pageSize: pageSize,
      );
      await _cacheArticles(cacheKey, response.articles);
      final localized = await _translation.localizeArticles(
        response.articles,
        locale: locale,
      );
      return PageResult(
          articles: localized, totalResults: response.totalResults);
    } on DioException catch (e) {
      // Last-resort fallback — server error despite being online.
      final cached = await _getCachedArticles(cacheKey);
      if (cached != null) {
        final localized = await _translation.localizeArticles(
          cached,
          locale: locale,
        );
        return PageResult(
            articles: localized,
            totalResults: localized.length,
            fromCache: true);
      }
      throw _mapDioError(e);
    }
  }

  // ── Recommended (paginated) ────────────────────────────────────────────────

  Future<PageResult> getRecommendedPage({
    String country = 'us',
    required int page,
    bool forceRefresh = false,
    String locale = 'en',
  }) async {
    final cacheKey = '${AppConstants.recommendedPageKeyPrefix}$page';

    // ① Offline — serve cache instantly.
    final online = await _network.isConnected;
    if (!online) {
      final cached = await _getCachedPage(cacheKey, isOffline: true);
      if (cached != null) {
        final localized = await _translation.localizeArticles(
          cached.articles,
          locale: locale,
        );
        return PageResult(
            articles: localized,
            totalResults: cached.totalResults,
            fromCache: true);
      }
      throw _offlineNoCache();
    }

    // Online path.
    if (!forceRefresh) {
      final cached = await _getCachedPage(cacheKey, isOffline: false);
      if (cached != null) {
        final localized = await _translation.localizeArticles(
          cached.articles,
          locale: locale,
        );
        return PageResult(
            articles: localized, totalResults: cached.totalResults);
      }
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

      final localized = await _translation.localizeArticles(
        response.articles,
        locale: locale,
      );

      return PageResult(
          articles: localized, totalResults: response.totalResults);
    } on DioException catch (e) {
      final cached = await _getCachedPage(cacheKey, isOffline: true);
      if (cached != null) {
        final localized = await _translation.localizeArticles(
          cached.articles,
          locale: locale,
        );
        return PageResult(
            articles: localized,
            totalResults: cached.totalResults,
            fromCache: true);
      }
      throw _mapDioError(e);
    }
  }

  // ── Cache management ───────────────────────────────────────────────────────

  Future<void> clearRecommendedCache() async {
    await Future.wait(List.generate(
        AppConstants.maxCachablePages,
        (i) => _db.delete(
              '${AppConstants.recommendedPageKeyPrefix}${i + 1}',
            )));
  }

  // ── Private helpers ────────────────────────────────────────────────────────

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
    await _db.put('${key}_articles', result.articles);
    await _db.put('${key}_total', result.totalResults);
  }

  Future<PageResult?> _getCachedPage(String key,
      {bool isOffline = false}) async {
    final articles = await _getCachedArticles('${key}_articles');
    final total = await _db.get<int>('${key}_total');
    if (articles == null || total == null) return null;
    return PageResult(
      articles: articles,
      totalResults: total,
      fromCache: isOffline,
    );
  }

  String _headlinesCacheKey(String? category) => category != null
      ? '${AppConstants.cachedHeadlinesKey}_$category'
      : AppConstants.cachedHeadlinesKey;

  String _offlineNoCache() =>
      'You\'re offline and there\'s no cached news yet. '
      'Please connect to the internet for your first load.';

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'No internet connection. Showing cached news.';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401) {
          return 'Invalid API key. Please check your configuration.';
        }
        if (code == 429) return 'Too many requests. Please wait a moment.';
        return 'Server error ($code). Please try again later.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
