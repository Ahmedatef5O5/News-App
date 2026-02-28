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
    return NewsApiResponse(
      status: map['status'] as String,
      totalResults: map['totalResults'] as int,
      articles: map['articles'] != null
          ? List<Article>.from(
              (map['articles'] as List).map<Article?>(
                (x) => Article.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }
}
