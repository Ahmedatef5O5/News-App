import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../translation/article_translation_repository.dart';

const String _settingsBox = 'settings_box';
const String _localeModeKey = 'locale_mode';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit({required ArticleTranslationRepository translationRepo})
      : _translationRepo = translationRepo,
        super(const Locale('en'));

  final ArticleTranslationRepository _translationRepo;
  Box? _box;
  bool _initialized = false;

  // ── Initialisation ──────────────────────────────────────────────────────────

  Future<void> init() async {
    _box = await _openBox();
    _initialized = true;
    final saved = _box!.get(_localeModeKey, defaultValue: 'en') as String;
    emit(_fromString(saved));
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  String get languageCode => state.languageCode;

  bool get isArabic => state.languageCode == 'ar';
  bool get isEnglish => state.languageCode == 'en';

  Future<void> setLocale(Locale locale) async {
    if (locale == state) return;

    if (!_initialized) {
      _box = await _openBox();
      _initialized = true;
    }

    await _box!.put(_localeModeKey, locale.languageCode);
    await _translationRepo.clearCache();
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
