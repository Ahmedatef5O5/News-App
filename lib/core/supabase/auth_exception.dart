enum AuthErrorCode {
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  invalidEmail,
  emailNotConfirmed,
  network,
  sessionExpired,
  rateLimit,
  agreeToTerms,
  passwordResetSent,
  unknown,
}

sealed class AuthUserException implements Exception {
  const AuthUserException(this.code, [this.extra]);

  final AuthErrorCode code;
  final String? extra;
}

/// Wrong email / password combination.
final class InvalidCredentialsException extends AuthUserException {
  const InvalidCredentialsException() : super(AuthErrorCode.invalidCredentials);
}

/// Account already exists with that email.
final class EmailAlreadyInUseException extends AuthUserException {
  const EmailAlreadyInUseException() : super(AuthErrorCode.emailAlreadyInUse);
}

/// Weak password rejected by Supabase.
final class WeakPasswordException extends AuthUserException {
  const WeakPasswordException() : super(AuthErrorCode.weakPassword);
}

/// Email format is not valid.
final class InvalidEmailException extends AuthUserException {
  const InvalidEmailException() : super(AuthErrorCode.invalidEmail);
}

/// No network / timeout.
final class NetworkException extends AuthUserException {
  const NetworkException() : super(AuthErrorCode.network);
}

/// User cancelled or session expired.
final class SessionExpiredException extends AuthUserException {
  const SessionExpiredException() : super(AuthErrorCode.sessionExpired);
}

/// Rate-limited by Supabase.
final class RateLimitException extends AuthUserException {
  const RateLimitException() : super(AuthErrorCode.rateLimit);
}

/// Reset email sent – not really an error but used to signal success
/// through the same result channel when needed.
final class PasswordResetSentException extends AuthUserException {
  const PasswordResetSentException(String email)
      : super(AuthErrorCode.passwordResetSent, email);
}

/// Anything that doesn't fit the above categories.
final class UnknownAuthException extends AuthUserException {
  const UnknownAuthException([String? message])
      : super(AuthErrorCode.unknown, message);
}

AuthUserException mapSupabaseError(Object error) {
  final msg = error.toString().toLowerCase();

  if (msg.contains('invalid login credentials')) {
    return const InvalidCredentialsException();
  }

  if (msg.contains('already registered')) {
    return const EmailAlreadyInUseException();
  }

  if (msg.contains('weak password')) {
    return const WeakPasswordException();
  }

  if (msg.contains('invalid email')) {
    return const InvalidEmailException();
  }

  if (msg.contains('network') || msg.contains('timeout')) {
    return const NetworkException();
  }

  if (msg.contains('session expired')) {
    return const SessionExpiredException();
  }

  if (msg.contains('rate limit')) {
    return const RateLimitException();
  }

  return UnknownAuthException(msg);
}
