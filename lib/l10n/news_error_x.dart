import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:news_app/core/exceptions/news_exceptions.dart';

extension NewsExceptionL10n on NewsException {
  String message(AppLocalizations l10n) => switch (code) {
        NewsErrorCode.offlineNoCache => l10n.offlineNoCacheYet,
        NewsErrorCode.networkTimeout => l10n.errorConnectionFailed,
        NewsErrorCode.unauthorized => l10n.errorInvalidCredentials,
        NewsErrorCode.rateLimited => l10n.errorTooManyAttempts,
        _ => l10n.somethingWentWrong,
      };
}
