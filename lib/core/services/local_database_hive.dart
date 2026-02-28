import 'package:hive_flutter/adapters.dart';
import 'package:news_app/core/utilities/constants/app_constants.dart';
import '../models/article_model.dart';

class LocalDatabaseHive {
  Future<Box> _getBox() async {
    return await Hive.openBox(AppConstants.localDatabaseBox);
  }

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ArticleAdapter());
    Hive.registerAdapter(SourceAdapter());
  }

  Future<void> saveData<T>(String key, T value) async {
    final box = await _getBox();
    await box.put(key, value);
  }

  Future<T?> getData<T>(String key) async {
    final box = await _getBox();
    return box.get(key) as T?;
  }

  Future<void> deleteData<T>(String key) async {
    final box = await _getBox();
    await box.delete(key);
  }

  Future<void> clearData() async {
    final box = await _getBox();
    await box.clear();
  }
}
