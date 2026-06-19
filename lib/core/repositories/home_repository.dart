import 'package:dio/dio.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/models/article_model.dart';
import 'package:news_app/core/network/network_info.dart';
import '../../features/home/domain/repositories/home_repository_contract.dart';
import '../cache/news_cache_manager.dart';
import '../exceptions/news_exceptions.dart';
import '../models/news_api_response.dart';
import '../translation/article_translation_repository.dart';

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
  HomeRepository({
    required HomeRepositoryContract services,
    required NewsCacheManager cache,
    required NetworkInfo networkInfo,
    required ArticleTranslationRepository translationRepo,
  })  : _services = services,
        _cache = cache,
        _network = networkInfo,
        _translation = translationRepo;

  final HomeRepositoryContract _services;
  final NewsCacheManager _cache;
  final NetworkInfo _network;
  final ArticleTranslationRepository _translation;

  // ── Headlines (simple list) ───────────────────────────────────────────────

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
    final cacheKey = _cache.headlinesCacheKey(category, locale: locale);

    final probablyOnline = await _network.isConnected;

    if (!probablyOnline) {
      final cached = await _cache.getCachedArticles(cacheKey);
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
      // No cache — don't give up yet. Fall through and try the real call.
    } else if (!forceRefresh) {
      final cached = await _cache.getCachedArticles(cacheKey);
      if (cached != null) {
        final localized = await _translation.localizeArticles(
          cached,
          locale: locale,
        );
        return PageResult(articles: localized, totalResults: localized.length);
      }
    }

    try {
      final NewsApiResponse response;

      if (locale == 'ar') {
        final arabicQuery = _getArabicQueryForCategory(category);
        response = await _services.getEverything(
          q: arabicQuery,
          pageSize: pageSize,
        );
      } else {
        response = await _services.getTopHeadlines(
          country: country,
          category: category,
          pageSize: pageSize,
        );
      }

      await _cache.cacheArticles(cacheKey, response.articles);
      final localized = await _translation.localizeArticles(
        response.articles,
        locale: locale,
      );
      return PageResult(
          articles: localized, totalResults: response.totalResults);
    } on DioException catch (e) {
      // Last-resort fallback — failed despite the probe saying "online",
      // or genuinely offline and we only got here because there was no
      // cache to serve above.
      final cached = await _cache.getCachedArticles(cacheKey);
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
      if (_isConnectivityError(e)) {
        throw _offlineNoCache();
      }
      throw mapDioError(e);
    }
  }

  // ── Recommended (paginated) ───────────────────────────────────────────────

  Future<PageResult> getRecommendedPage({
    String country = 'us',
    required int page,
    bool forceRefresh = false,
    String locale = 'en',
  }) async {
    final cacheKey = _cache.recommendedCacheKey(page, locale: locale);

    // ① Connectivity probe — hint only, doesn't block the real call.
    final probablyOnline = await _network.isConnected;

    if (!probablyOnline) {
      final cached = await _cache.getCachedPage(cacheKey, isOffline: true);
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
      // No cache — fall through and try the real network call.
    } else if (!forceRefresh) {
      final cached = await _cache.getCachedPage(cacheKey, isOffline: false);
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
      final NewsApiResponse response;

      if (locale == 'ar') {
        response = await _services.getEverything(
          q: _getArabicQueryForCategory(null),
          pageSize: AppConstants.recommendedPageSize,
        );
      } else {
        response = await _services.getRecommended(
          country: country,
          page: page,
        );
      }

      final result = PageResult(
        articles: response.articles,
        totalResults: response.totalResults,
      );

      await _cache.cachePage(cacheKey, result);

      final localized = await _translation.localizeArticles(
        response.articles,
        locale: locale,
      );

      return PageResult(
          articles: localized, totalResults: response.totalResults);
    } on DioException catch (e) {
      final cached = await _cache.getCachedPage(cacheKey, isOffline: true);
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
      if (_isConnectivityError(e)) {
        throw _offlineNoCache();
      }
      throw mapDioError(e);
    }
  }

  bool _isConnectivityError(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout;

  String _getArabicQueryForCategory(String? category) {
    switch (category) {
      case 'business':
        return 'اقتصاد OR أعمال OR بورصة OR استثمار';
      case 'entertainment':
        return 'ترفيه OR فن OR سينما OR موسيقى';
      case 'health':
        return 'صحة OR طب OR مرض OR علاج';
      case 'science':
        return 'علوم OR اكتشاف OR فضاء OR تكنولوجيا';
      case 'sports':
        return 'رياضة OR كرة قدم OR بطولة OR ملعب';
      case 'technology':
        return 'تقنية OR ذكاء اصطناعي OR إنترنت OR ابتكار';
      case 'general':
      case null:
      default:
        return 'أخبار عاجلة OR عاجل OR أحداث';
    }
  }

  NewsException _offlineNoCache() => const OfflineNoCacheException();
}
