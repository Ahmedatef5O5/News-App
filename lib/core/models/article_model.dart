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

extension ArticleExtension on Article {
  String get formattedDate {
    final DateTime? rawDate = DateTime.tryParse(
      publishedAt ?? DateTime.now().toString(),
    );
    return rawDate != null
        ? DateFormat.yMMMd().format(rawDate)
        : DateFormat.yMMMd().format(DateTime.now());
  }

  String? get shortAuthor {
    if (author != null && author!.isNotEmpty) {
      String cleanAuthorName = author!.replaceAll(',', '').trim();
      List<String> words = cleanAuthorName.split(' ');
      String result;
      if (words.length > 2) {
        result = '${words[0]} ${words[1]}';
      } else {
        result = cleanAuthorName;
      }

      const int maxChars = 14;
      if (result.length > maxChars) {
        return '${result.substring(0, maxChars)}...';
      }

      return result;
    } else {
      return null;
    }
  }
}
