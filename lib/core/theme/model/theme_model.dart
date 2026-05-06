import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String _themeBox = 'settings_box';
const String _themeModeKey = 'theme_mode';
const String _themeChosenKey = 'theme_chosen';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  Box? _box;

  Future<void> init() async {
    _box = await _openBox();
    final saved = _box!.get(_themeModeKey, defaultValue: 'system') as String;
    emit(_fromString(saved));
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Whether the user has previously made a theme choice.
  bool get hasChosen =>
      _box?.get(_themeChosenKey, defaultValue: false) as bool? ?? false;

  Future<void> setTheme(ThemeMode mode) async {
    await _box?.put(_themeModeKey, _toString(mode));
    await _box?.put(_themeChosenKey, true);
    emit(mode);
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
  }

  bool get isDark => state == ThemeMode.dark;

  static Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_themeBox)) return Hive.box(_themeBox);
    return Hive.openBox(_themeBox);
  }

  static ThemeMode _fromString(String s) => switch (s) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _toString(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      };
}
