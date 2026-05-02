import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
part 'article_model.g.dart';

@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0)
  final Source? source;
  @HiveField(1)
  final String? author;
  @HiveField(2)
  final String? title;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final String? url;
  @HiveField(5)
  final String? urlToImage;
  @HiveField(6)
  final String? publishedAt;
  @HiveField(7)
  final String? content;

  Article(
    this.source,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'source': source?.toMap(),
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      map['source'] != null
          ? Source.fromMap(map['source'] as Map<String, dynamic>)
          : null,
      map['author'] != null ? map['author'] as String : null,
      map['title'] != null ? map['title'] as String : null,
      map['description'] != null ? map['description'] as String : null,
      map['url'] != null ? map['url'] as String : null,
      map['urlToImage'] != null ? map['urlToImage'] as String : null,
      map['publishedAt'] != null ? map['publishedAt'] as String : null,
      map['content'] != null ? map['content'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Article.fromJson(String source) =>
      Article.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Unique identifier based on URL or title for Hive key operations.
  String get uniqueId =>
      url ?? title ?? publishedAt ?? DateTime.now().toIso8601String();
}

@HiveType(typeId: 1)
class Source {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String? name;

  const Source({this.id, this.name});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name};
  }

  factory Source.fromMap(Map<String, dynamic> map) {
    return Source(
      id: map['id'] != null ? map['id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
    );
  }
}

/// Clean computed properties on Article — no UI logic in the model.

extension ArticleExtension on Article {
  /// Human-readable date like "Apr 30, 2026".
  String get formattedDate {
    final parsed = DateTime.tryParse(publishedAt ?? '');
    return parsed != null
        ? DateFormat.yMMMd().format(parsed)
        : DateFormat.yMMMd().format(DateTime.now());
  }

  /// Shortened author — max 2 words, max 20 chars.
  String? get shortAuthor {
    final raw = author?.trim();
    if (raw == null || raw.isEmpty) return null;
    final clean = raw.replaceAll(',', '').trim();
    final words = clean.split(' ');
    final twoWords = words.length > 2 ? '${words[0]} ${words[1]}' : clean;
    return twoWords.length > 20 ? '${twoWords.substring(0, 20)}…' : twoWords;
  }

  /// Strip HTML tags and truncation markers like "[+1046 chars]".
  String get cleanDescription {
    if (description == null || description!.isEmpty) {
      return 'No description available.';
    }
    return _stripHtml(description!);
  }

  /// Strip HTML and remove the "[+N chars]" truncation NewsAPI adds.
  String get cleanContent {
    if (content == null || content!.isEmpty) return '';
    final stripped = _stripHtml(content!);
    // Remove "[+1234 chars]" pattern
    return stripped.replaceAll(RegExp(r'\[\+\d+ chars?\]'), '').trim();
  }

  String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // remove HTML tags
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .trim();
  }

  /// Whether this article has a valid image.
  bool get hasImage =>
      urlToImage != null &&
      urlToImage!.isNotEmpty &&
      urlToImage!.startsWith('http');

  /// Whether the article URL can be opened in browser.
  bool get hasUrl => url != null && url!.isNotEmpty && url!.startsWith('http');
}
