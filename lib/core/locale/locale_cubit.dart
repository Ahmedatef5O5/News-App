import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

const String _settingsBox = 'settings_box';
const String _localeModeKey = 'locale_mode';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  Box? _box;

  // ── Initialisation ──────────────────────────────────────────────────────────

  Future<void> init() async {
    _box = await _openBox();
    final saved = _box!.get(_localeModeKey, defaultValue: 'en') as String;
    emit(_fromString(saved));
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  String get languageCode => state.languageCode;

  bool get isArabic => state.languageCode == 'ar';
  bool get isEnglish => state.languageCode == 'en';

  Future<void> setLocale(Locale locale) async {
    await _box?.put(_localeModeKey, locale.languageCode);
    emit(locale);
  }

  /// Flips between English and Arabic.
  Future<void> toggle() async {
    final next = isArabic ? const Locale('en') : const Locale('ar');
    await setLocale(next);
  }

  // helpers

  static Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_settingsBox)) {
      return Hive.box(_settingsBox);
    }
    return Hive.openBox(_settingsBox);
  }

  static Locale _fromString(String code) => switch (code) {
        'ar' => const Locale('ar'),
        _ => const Locale('en'),
      };
}
