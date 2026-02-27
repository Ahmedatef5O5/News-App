import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabaseServices {
  // ArticleModel -> toMap -> json.encode -> String
  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // List<ArticleModel> -> toMap -> json.encode -> String -> List<String>
  Future<void> setStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  // String -> json.decode -> fromMap -> ArticleModel
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // List<String> -> json.decode -> fromMap -> ArticleModel -> List<ArticleModel>
  Future<List<String>?> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }
}
