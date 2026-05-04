import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/models/article_model.dart';
import '../services/favorite_services.dart';
import 'favorite_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({FavoritesService? service})
      : _service = service ?? FavoritesService(),
        super(const FavoritesState()) {
    loadFavorites();
  }

  final FavoritesService _service;

  Future<void> loadFavorites() async {
    emit(state.copyWith(status: FavStatus.loading));
    try {
      final articles = await _service.getFavorites();
      emit(state.copyWith(status: FavStatus.success, articles: articles));
    } catch (e) {
      emit(state.copyWith(status: FavStatus.failure, error: e.toString()));
    }
  }

  Future<void> toggleFavorite(Article article) async {
    try {
      final isSaved = state.isSaved(article);
      final updated = List<Article>.from(state.articles);

      if (isSaved) {
        updated.removeWhere((a) => a.uniqueId == article.uniqueId);
      } else {
        updated.add(article);
      }

      emit(state.copyWith(articles: updated, status: FavStatus.success));
      await _service.toggleFavorite(article);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  bool isSaved(Article article) => state.isSaved(article);
}
