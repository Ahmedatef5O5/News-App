import 'dart:convert';

import 'package:news_app/core/models/news_api_response.dart';
import 'package:news_app/core/utilities/constants/app_constants.dart';

import '../../../core/services/local_database_services.dart';

class FavoriteServices {
  final localServices = LocalDatabaseServices();
  final String _favKey = AppConstants.favKey;

  //
  Future<List<Article>> getFavorites() async {
    final List<String>? favArticles = await localServices.getStringList(
      _favKey,
    );
    if (favArticles == null || favArticles.isEmpty) {
      return [];
    }
    return favArticles
        .map((article) => Article.fromJson(json.decode(article)))
        .toList();
  }

  // add or delete
  Future<void> toggleFavorite(Article article) async {
    final List<String> currentData =
        await localServices.getStringList(_favKey) ?? [];

    String articleJson = json.encode(article.toJson());
    if (currentData.contains(articleJson)) {
      currentData.remove(articleJson);
    } else {
      currentData.add(articleJson);
    }

    await localServices.setStringList(_favKey, currentData);
  }
}
