class TranslationRateLimitException implements Exception {
  const TranslationRateLimitException();
  @override
  String toString() => 'Translation API rate limit exceeded (429).';
}

class TranslationNetworkException implements Exception {
  final int statusCode;
  const TranslationNetworkException(this.statusCode);
  @override
  String toString() => 'Translation API error: $statusCode';
}

class LibreRateLimitException implements Exception {
  const LibreRateLimitException();

  @override
  String toString() =>
      'LibreTranslate rate limit exceeded or service unavailable.';
}

class LibreNetworkException implements Exception {
  final int statusCode;
  const LibreNetworkException(this.statusCode);

  @override
  String toString() => 'LibreTranslate API error: $statusCode';
}

enum TranslationErrorCode {
  offline,
}

class TranslationOfflineException implements Exception {
  const TranslationOfflineException();
  TranslationErrorCode get code => TranslationErrorCode.offline;
}
