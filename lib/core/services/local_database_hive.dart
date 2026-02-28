import 'package:hive_flutter/adapters.dart';
import 'package:news_app/core/utilities/constants/app_constants.dart';
import '../models/article_model.dart';

class LocalDatabaseHive {
  Future<Box> _getBox() async {
    return await Hive.openBox(AppConstants.localDatabaseBox);
  }

  static void initHive() {
    Hive.initFlutter();
    Hive.registerAdapter(ArticleAdapter());
    Hive.registerAdapter(SourceAdapter());
  }

  Future<void> saveData<T>(String key, T value) async {
    final box = await _getBox();
    await box.put(key, value);
  }

  Future<void> getData<T>(String key, T value) async {
    final box = await _getBox();
    await box.get(key);
  }

  Future<void> deleteData<T>(String key, T value) async {
    final box = await _getBox();
    await box.delete(key);
  }

  Future<void> clearData() async {
    final box = await _getBox();
    await box.clear();
  }
}
