import 'package:flutter/widgets.dart';
import 'package:news_app/core/supabase/auth_exception.dart';
import 'package:news_app/l10n/app_localizations_x.dart';

extension AuthErrorCodeX on AuthErrorCode {
  String localizedMessage(BuildContext context, {String? extra}) {
    final l10n = context.l10n;
    return switch (this) {
      AuthErrorCode.invalidCredentials => l10n.errorInvalidCredentials,
      AuthErrorCode.emailAlreadyInUse => l10n.errorEmailAlreadyInUse,
      AuthErrorCode.weakPassword => l10n.validationPasswordTooShort,
      AuthErrorCode.invalidEmail => l10n.validationEmailInvalid,
      AuthErrorCode.emailNotConfirmed => l10n.validationEmailInvalidAlt,
      AuthErrorCode.network => l10n.errorConnectionFailed,
      AuthErrorCode.sessionExpired => l10n.errorSessionExpired,
      AuthErrorCode.rateLimit => l10n.errorTooManyAttempts,
      AuthErrorCode.agreeToTerms => l10n.authErrAgreeToTerms,
      AuthErrorCode.passwordResetSent =>
        l10n.authErrPasswordResetSent(extra ?? ''),
      AuthErrorCode.unknown => l10n.authErrUnknown,
    };
  }
}
