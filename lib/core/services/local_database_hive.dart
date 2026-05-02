import 'package:hive_flutter/adapters.dart';
import 'package:news_app/core/constants/app_constants.dart';
import '../models/article_model.dart';

/// Singleton Hive wrapper.
/// Opens box once and reuses it — no repeated openBox() calls.

class LocalDatabaseHive {
// singleton Pattern
  LocalDatabaseHive._();
  static final LocalDatabaseHive instance = LocalDatabaseHive._();

  Box? _box;

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ArticleAdapter());
    Hive.registerAdapter(SourceAdapter());
  }

  Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(AppConstants.articlesBox);
    return _box!;
  }

  Future<void> put<T>(String key, T value) async {
    final box = await _getBox();
    await box.put(key, value);
  }

  Future<T?> get<T>(String key) async {
    final box = await _getBox();
    return box.get(key) as T?;
  }

  Future<void> delete<T>(String key) async {
    final box = await _getBox();
    await box.delete(key);
  }

  Future<void> clear() async {
    final box = await _getBox();
    await box.clear();
  }
}
