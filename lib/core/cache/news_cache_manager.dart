import '../constants/app_constants.dart';
import '../models/article_model.dart';
import '../repositories/home_repository.dart';
import '../services/local_database_hive.dart';

class NewsCacheManager {
  final LocalDatabaseHive _db;

  const NewsCacheManager({required LocalDatabaseHive db}) : _db = db;

  String headlinesCacheKey(String? category, {required String locale}) {
    final base = category != null
        ? '${AppConstants.cachedHeadlinesKey}_$category'
        : AppConstants.cachedHeadlinesKey;
    return '${base}_$locale';
  }

  String recommendedCacheKey(int page, {required String locale}) {
    return '${AppConstants.recommendedPageKeyPrefix}${page}_$locale';
  }

  Future<void> cacheArticles(String key, List<Article> articles) =>
      _db.put(key, articles);

  Future<List<Article>?> getCachedArticles(String key) async {
    final raw = await _db.get<List<dynamic>>(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return raw.cast<Article>();
    } catch (_) {
      return null;
    }
  }

  Future<void> cachePage(String key, PageResult result) async {
    await _db.put('${key}_articles', result.articles);
    await _db.put('${key}_total', result.totalResults);
  }

  Future<PageResult?> getCachedPage(String key,
      {bool isOffline = false}) async {
    final articles = await getCachedArticles('${key}_articles');
    final total = await _db.get<int>('${key}_total');
    if (articles == null || total == null) return null;
    return PageResult(
      articles: articles,
      totalResults: total,
      fromCache: isOffline,
    );
  }

  Future<void> clearRecommendedCache() async {
    await Future.wait(List.generate(
        AppConstants.maxCachablePages,
        (i) => _db.delete(
              '${AppConstants.recommendedPageKeyPrefix}${i + 1}',
            )));
  }

  Future<void> clearAll() async {
    // to clear all cached data, we can either clear the entire box or delete specific keys.
  }
}
