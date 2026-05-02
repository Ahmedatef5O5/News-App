import 'package:news_app/core/secrets/app_secrets.dart';

abstract final class AppConstants {
  static const String appName = 'NewsWave';

  // ── API ──────────────────────────────────────────────────────────────────

  static String apiKey = AppSecrets.newsApiKey;
  static const String baseUrl = 'https://newsapi.org';
  static const String everything = '/v2/everything';
  static const String topHeadlines = '/v2/top-headlines';

  // ── Hive boxes ───────────────────────────────────────────────────────────
  static const String articlesBox = 'articles_box';
  static const String favKey = 'favorite_articles';
  static const String cachedHeadlinesKey = 'cached_headlines';
  static const String cachedRecommendedKey = 'cached_recommended';

  // ── Pagination ───────────────────────────────────────────────────────────
  static const int pageSize = 15;
  static const int headlinesPageSize = 10;

  // ── Search Debounce ──────────────────────────────────────────────────────
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // ── Placeholder image ────────────────────────────────────────────────────
  static const String placeholderImageUrl =
      'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800&q=80';
}

/// App-wide categories for news filtering.
enum NewsCategory {
  general('General', 'general'),
  business('Business', 'business'),
  technology('Technology', 'technology'),
  sports('Sports', 'sports'),
  health('Health', 'health'),
  entertainment('Entertainment', 'entertainment'),
  science('Science', 'science');

  const NewsCategory(this.label, this.value);
  final String label;
  final String value;
}
