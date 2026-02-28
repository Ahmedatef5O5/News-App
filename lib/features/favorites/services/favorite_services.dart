import 'dart:convert';
import 'package:news_app/core/services/local_database_hive.dart';
import 'package:news_app/core/utilities/constants/app_constants.dart';
import '../../../core/models/article_model.dart';
import '../../../core/services/local_database_services.dart';

class FavoriteServices {
  // final localServices = LocalDatabaseServices();
  final localHive = LocalDatabaseHive();
  final String _favKey = AppConstants.favKey;

  //
  Future<List<Article>> getFavorites() async {
    final List<dynamic>? favArticles =
        await localHive.getData<List<dynamic>>(_favKey);
    if (favArticles == null || favArticles.isEmpty) {
      return [];
    }
    return favArticles.cast<Article>();

    // final List<String>? favArticles = await localServices.getStringList(
    //   _favKey,
    // );
    // return favArticles
    //     .map((article) => Article.fromJson(json.decode(article)))
    //     .toList();
  }

  // add or delete
  Future<void> toggleFavorite(Article article) async {
    List<Article> favorites = await getFavorites();
    int index =
        favorites.indexWhere((element) => element.title == article.title);
    index == -1 ? favorites.add(article) : favorites.removeAt(index);
    await localHive.saveData(_favKey, favorites);

    // final List<String> currentData =
    //     await localServices.getStringList(_favKey) ?? [];

    // String articleJson = json.encode(article.toJson());
    // if (currentData.contains(articleJson)) {
    //   currentData.remove(articleJson);
    // } else {
    //   currentData.add(articleJson);
    // }

    // await localServices.setStringList(_favKey, currentData);
  }
}
