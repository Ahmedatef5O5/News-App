sealed class AuthUserException implements Exception {
  const AuthUserException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Wrong email / password combination.
final class InvalidCredentialsException extends AuthUserException {
  const InvalidCredentialsException()
      : super('Invalid email or password. Please try again.');
}

/// Account already exists with that email.
final class EmailAlreadyInUseException extends AuthUserException {
  const EmailAlreadyInUseException()
      : super('An account with this email already exists.');
}

/// Weak password rejected by Supabase.
final class WeakPasswordException extends AuthUserException {
  const WeakPasswordException()
      : super('Password must be at least 6 characters.');
}

/// Email format is not valid.
final class InvalidEmailException extends AuthUserException {
  const InvalidEmailException() : super('Please enter a valid email address.');
}

/// No network / timeout.
final class NetworkException extends AuthUserException {
  const NetworkException()
      : super('Connection failed. Check your internet and try again.');
}

/// User cancelled or session expired.
final class SessionExpiredException extends AuthUserException {
  const SessionExpiredException()
      : super('Your session has expired. Please sign in again.');
}

/// Rate-limited by Supabase.
final class RateLimitException extends AuthUserException {
  const RateLimitException()
      : super('Too many attempts. Please wait a moment and try again.');
}

/// Reset email sent – not really an error but used to signal success
/// through the same result channel when needed.
final class PasswordResetSentException extends AuthUserException {
  const PasswordResetSentException(String email)
      : super('A password reset link has been sent to $email.');
}

/// Anything that doesn't fit the above categories.
final class UnknownAuthException extends AuthUserException {
  const UnknownAuthException(super.message);
}

/// Helper to map raw Supabase / network error strings to typed exceptions.
AuthUserException mapSupabaseError(Object error) {
  final msg = error.toString().toLowerCase();

  if (msg.contains('invalid login credentials') ||
      msg.contains('invalid password') ||
      msg.contains('user not found')) {
    return const InvalidCredentialsException();
  }
  if (msg.contains('email already registered') ||
      msg.contains('user already registered') ||
      msg.contains('already in use')) {
    return const EmailAlreadyInUseException();
  }
  if (msg.contains('password should be at least') ||
      msg.contains('weak password')) {
    return const WeakPasswordException();
  }
  if (msg.contains('invalid email') || msg.contains('not a valid email')) {
    return const InvalidEmailException();
  }
  if (msg.contains('network') ||
      msg.contains('socket') ||
      msg.contains('timeout') ||
      msg.contains('connection')) {
    return const NetworkException();
  }
  if (msg.contains('session_not_found') ||
      msg.contains('jwt expired') ||
      msg.contains('session expired')) {
    return const SessionExpiredException();
  }
  if (msg.contains('rate limit') || msg.contains('too many requests')) {
    return const RateLimitException();
  }
  return UnknownAuthException(error.toString());
}
