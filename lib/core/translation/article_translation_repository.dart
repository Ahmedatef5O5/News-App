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
    if (_isArabic(article.title ?? article.description ?? '')) {
      return article;
    }

    final id = _safeKey(article.uniqueId);
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
