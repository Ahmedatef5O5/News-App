import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:news_app/core/models/article_model.dart';
import 'package:news_app/core/services/local_database_hive.dart';
import 'package:news_app/core/translation/translation_service.dart';

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

    final results = <Article>[];
    const chunkSize = 3;

    for (var i = 0; i < articles.length; i += chunkSize) {
      final chunk = articles.skip(i).take(chunkSize).toList();
      final translated = Future.wait(chunk.map(_translateArticle));
      results.addAll(await translated);
    }
    return results;
  }

  Future<Article> translateSingle(
    Article article, {
    required String locale,
  }) async {
    if (locale != 'ar') return article;

    return _translateArticle(article);
  }

  Future<Article> _translateArticle(Article article) async {
    final titleIsArabic = _isArabic(article.title ?? '');
    final descIsArabic = _isArabic(article.cleanDescription);
    final contentIsArabic = _isArabic(article.cleanContent);

    final arabicCount =
        [titleIsArabic, descIsArabic, contentIsArabic].where((v) => v).length;

    if (arabicCount >= 2) return article;

    // ── Cache check ───────────────────────────────────────────────────────
    final id = _safeKey(article.uniqueId);
    final cacheKey = '$_prefix$id';

    final cached = await _fromCache(cacheKey);
    if (cached != null) return cached;

    try {
      final futures = await Future.wait([
        titleIsArabic
            ? Future.value(article.title ?? '')
            : _translateSafe(article.title ?? '', article.title ?? ''),
        // description
        descIsArabic
            ? Future.value(article.cleanDescription)
            : _translateSafe(
                article.cleanDescription, article.cleanDescription),
        // content
        contentIsArabic
            ? Future.value(article.cleanContent)
            : _translateSafe(article.cleanContent, article.cleanContent),
      ]);

      final result = Article(
        article.source,
        article.author,
        futures[0].isNotEmpty ? futures[0] : article.title,
        futures[1].isNotEmpty ? futures[1] : article.cleanDescription,
        article.url,
        article.urlToImage,
        article.publishedAt,
        futures[2].isNotEmpty ? futures[2] : article.cleanContent,
      );

      await _toCache(cacheKey, result);
      return result;
    } catch (_) {
      return article;
    }
  }

  Future<String> _translateSafe(String text, String fallback) async {
    if (text.trim().isEmpty) return fallback;
    try {
      final result = await _service.translate(text, from: 'en', to: 'ar');
      return result.trim().isEmpty ? fallback : result;
    } catch (_) {
      return fallback;
    }
  }

  String _safeKey(String raw) {
    final bytes = utf8.encode(raw);
    return md5.convert(bytes).toString();
  }

  bool _isArabic(String text) {
    if (text.trim().isEmpty) return false;
    final arabicChars =
        text.codeUnits.where((c) => c >= 0x0600 && c <= 0x06FF).length;
    return arabicChars / text.length > 0.30;
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

  Future<void> clearCache() async {
    final keys = await _db.keys();
    final translationKeys =
        keys.where((k) => k.toString().startsWith(_prefix)).toList();
    await Future.wait(translationKeys.map((k) => _db.delete(k.toString())));
  }
}
