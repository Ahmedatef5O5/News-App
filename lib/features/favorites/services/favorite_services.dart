import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/models/article_model.dart';
import 'package:news_app/core/services/local_database_hive.dart';

class FavoritesService {
  final _db = LocalDatabaseHive.instance;

  Future<List<Article>> getFavorites() async {
    final raw = await _db.get<List<dynamic>>(AppConstants.favKey);
    if (raw == null || raw.isEmpty) return [];
    return raw.cast<Article>();
  }

  Future<void> toggleFavorite(Article article) async {
    final current = await getFavorites();
    final exists = current.any((a) => a.uniqueId == article.uniqueId);
    if (exists) {
      current.removeWhere((a) => a.uniqueId == article.uniqueId);
    } else {
      current.add(article);
    }
    await _db.put(AppConstants.favKey, current);
  }
}
