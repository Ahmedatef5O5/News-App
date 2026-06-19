import 'package:hive_flutter/adapters.dart';
import 'package:news_app/core/constants/app_constants.dart';
import '../../features/profile/model/profile_model.dart';
import '../models/article_model.dart';

class LocalDatabaseHive {
// singleton Pattern
  LocalDatabaseHive._();
  static final LocalDatabaseHive instance = LocalDatabaseHive._();

  Box? _box;

  // ─── Initialisation (call once in main()) ─────────────────────────────────

  /// Registers all Hive adapters and opens the articles box.

  static Future<void> initHive() async {
    await Hive.initFlutter();

    // ── Articles (typeId 0 & 1) ───────────────────────────────────────────
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ArticleAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SourceAdapter());

    // ── Profile (typeId 2) ────────────────────────────────────────────────
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ProfileModelAdapter());
    }
  }

  Future<Iterable<dynamic>> keys() async {
    final box = await _getBox();
    return box.keys;
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
