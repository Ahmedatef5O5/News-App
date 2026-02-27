import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/models/news_api_response.dart';
import 'package:news_app/core/services/local_database_services.dart';
part 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit() : super(FavoriteInitial());

  final localServices = LocalDatabaseServices();
  final String _favKey = 'favorite_articles';

  //
  Future<void> getFavorites() async {
    emit(FavoriteLoading());
    try {
      final List<String>? data = await localServices.getStringList(_favKey);
      if (data == null || data.isEmpty) {
        emit(FavoriteLoaded([]));
      } else {
        final List<Article> articles = data
            .map((e) => Article.fromJson(json.decode(e)))
            .toList();
        emit(FavoriteLoaded(articles));
      }
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  //
  Future<void> toggleFavorite(Article article) async {
    try {
      final List<String> currentData =
          await localServices.getStringList(_favKey) ?? [];

      String articleJson = json.encode(article.toJson());
      if (currentData.contains(articleJson)) {
        currentData.remove(articleJson);
      } else {
        currentData.add(articleJson);
      }

      await localServices.setStringList(_favKey, currentData);
      getFavorites();
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }
}
