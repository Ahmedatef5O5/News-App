import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/models/news_api_response.dart';
import 'package:news_app/features/favorites/services/favorite_services.dart';
part 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit() : super(FavoriteInitial());

  final favoriteServices = FavoriteServices();
  //
  Future<void> getFavorites() async {
    emit(FavoriteLoading());
    try {
      final articles = await favoriteServices.getFavorites();
      if (articles.isEmpty) {
        emit(FavoriteLoaded([]));
      } else {
        emit(FavoriteLoaded(articles));
      }
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  //
  Future<void> toggleFavorite(Article article) async {
    try {
      await favoriteServices.toggleFavorite(article);
      getFavorites();
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }
}
