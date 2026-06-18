import 'package:news_app/core/translation/translation_service.dart';
import '../models/article_model.dart';
import '../services/local_database_hive.dart';

class ArticleTranslationRepository {
  ArticleTranslationRepository({
    required TranslationService translationService,
    required LocalDatabaseHive db,
  })  : _service = translationService,
        _db = db;

  final TranslationService _service;
  final LocalDatabaseHive _db;

  static const _prefix = 'tr_';

  Future<List<Article>> localizeArticles(
    List<Article> articles, {
    required String locale,
  }) async {
    if (locale != 'ar') return articles;
    return Future.wait(articles.map(_translateArticle));
  }

  Future<Article> translateSingle(
    Article article, {
    required String locale,
  }) async {
    if (locale != 'ar') return article;
    return _translateArticle(article);
  }

  Future<Article> _translateArticle(Article article) async {
    final id = article.uniqueId;
    final cacheKey = '$_prefix$id';

    final cached = await _fromCache(cacheKey);
    if (cached != null) return cached;

    final raw = [
      article.title ?? '',
      article.description ?? '',
      article.content ?? '',
    ];

    final translated = await _service.translateBatch(
      raw,
      from: 'en',
      to: 'ar',
    );

    final result = Article(
      article.source,
      article.author,
      translated[0].isNotEmpty ? translated[0] : article.title,
      translated[1].isNotEmpty ? translated[1] : article.description,
      article.url,
      article.urlToImage,
      article.publishedAt,
      translated[2].isNotEmpty ? translated[2] : article.content,
    );
    await _toCache(cacheKey, result);
    return result;
  }

  Future<Article?> _fromCache(String key) async {
    final raw = await _db.get<Map>(key);
    if (raw == null) return null;
    try {
      return Article.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> _toCache(String key, Article article) async {
    await _db.put(key, article.toMap());
  }

  /// امسح الـ cache لما المستخدم يرجع للإنجليزي (اختياري)
  Future<void> clearCache() async {
    // Hive مش بيوفر list keys بسهولة، الـ cache هيتمسح لما يتجدد الأخبار
  }
}
