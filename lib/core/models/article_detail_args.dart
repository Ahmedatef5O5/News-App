import 'package:news_app/core/models/article_model.dart';

class ArticleDetailArgs {
  const ArticleDetailArgs({
    required this.article,
    required this.heroTag,
  });

  final Article article;
  final String heroTag;
}
