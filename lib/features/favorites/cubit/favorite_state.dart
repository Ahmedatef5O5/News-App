import 'package:equatable/equatable.dart';
import '../../../core/models/article_model.dart';

enum FavStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  final FavStatus status;
  final List<Article> articles;
  final String? error;

  const FavoritesState({
    this.status = FavStatus.initial,
    this.articles = const [],
    this.error,
  });

  bool isSaved(Article article) =>
      articles.any((a) => a.uniqueId == article.uniqueId);

  FavoritesState copyWith({
    FavStatus? status,
    List<Article>? articles,
    String? error,
    bool clearError = false,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, articles, error];
}
