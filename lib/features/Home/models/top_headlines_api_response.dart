class TopHeadlinesApiResponse {
  final String status;
  final int totalResults;
  final List<Article>? articles;

  const TopHeadlinesApiResponse({
    required this.status,
    required this.totalResults,
    this.articles,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'totalResults': totalResults,
      'articles': articles!.map((x) => x.toMap()).toList(),
    };
  }

  factory TopHeadlinesApiResponse.fromMap(Map<String, dynamic> map) {
    return TopHeadlinesApiResponse(
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

class Article {
  final Source? source;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  const Article(
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
}

class Source {
  final String? id;
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
