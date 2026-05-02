import 'package:news_app/core/models/article_model.dart';

class NewsApiResponse {
  final String status;
  final int totalResults;
  final List<Article>? articles;

  const NewsApiResponse({
    required this.status,
    required this.totalResults,
    this.articles,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status,
      'totalResults': totalResults,
      'articles': articles!.map((x) => x.toMap()).toList(),
    };
  }

  factory NewsApiResponse.fromJson(Map<String, dynamic> map) {
    final rawArticles = map['articles'] as List<dynamic>? ?? [];
    return NewsApiResponse(
      status: map['status'] as String,
      totalResults: map['totalResults'] as int,
      articles: rawArticles
          .whereType<Map<String, dynamic>>()
          // Filter out "[Removed]" articles from NewsAPI
          .where((a) {
            final title = a['title'];
            final description = a['description'];
            final content = a['content'];

            return title != '[Removed]' &&
                description != '[Removed]' &&
                content != '[Removed]';
          })
          // .where((a) => a['title'] != '[Removed]')
          .map(Article.fromMap)
          .toList(),
    );
  }
}
