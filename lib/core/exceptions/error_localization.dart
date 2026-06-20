import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:news_app/core/exceptions/news_exceptions.dart';
import 'package:news_app/core/translation/translation_exceptions.dart';
import 'package:news_app/features/search/services/search_services.dart';
import 'package:news_app/l10n/news_error_x.dart';

String resolveErrorMessage(
  Object? error,
  AppLocalizations l10n, {
  String? fallback,
}) {
  final message = switch (error) {
    NewsException e => e.message(l10n),
    SearchOfflineException _ => l10n.searchOffline,
    TranslationOfflineException _ => l10n.translationOffline,
    _ => null,
  };

  return message ?? fallback ?? l10n.somethingWentWrong;
}
