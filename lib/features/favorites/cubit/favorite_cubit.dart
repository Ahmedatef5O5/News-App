import 'dart:async';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/models/article_model.dart';
import '../../../core/locale/locale_cubit.dart';
import '../../../core/translation/article_translation_repository.dart';
import '../services/favorite_services.dart';
import 'favorite_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({
    required FavoritesService service,
    required ArticleTranslationRepository translationRepo,
    required LocaleCubit localeCubit,
  })  : _service = service,
        _translation = translationRepo,
        _locale = localeCubit,
        super(const FavoritesState()) {
    loadFavorites();

    _localeSubscription = localeCubit.stream.listen((_) => loadFavorites());
  }

  final FavoritesService _service;
  final ArticleTranslationRepository _translation;
  final LocaleCubit _locale;
  StreamSubscription<Locale>? _localeSubscription;

  Future<void> loadFavorites() async {
    emit(state.copyWith(status: FavStatus.loading));
    try {
      final articles = await _service.getFavorites();

      final localized = await _translation.localizeArticles(
        articles,
        locale: _locale.state.languageCode,
      );

      emit(state.copyWith(status: FavStatus.success, articles: localized));
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

  @override
  Future<void> close() {
    _localeSubscription?.cancel();
    return super.close();
  }
}
