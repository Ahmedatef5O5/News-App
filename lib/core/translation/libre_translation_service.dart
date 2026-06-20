import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:news_app/core/translation/translation_exceptions.dart';
import 'package:news_app/core/translation/translation_service.dart';

class LibreTranslationService implements TranslationService {
  LibreTranslationService({
    http.Client? client,
    String baseUrl = 'https://libretranslate.com',
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl;

  final http.Client _client;
  final String _baseUrl;

  static const _separator = '\n<<<SEP>>>\n';

  @override
  Future<String> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    if (text.trim().isEmpty) return text;

    final uri = Uri.parse('$_baseUrl/translate');

    final http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'source': from,
          'target': to,
          'format': 'text',
        }),
      );
    } on SocketException {
      // DNS failure / connection refused — no network path at all.
      throw const TranslationOfflineException();
    } on http.ClientException {
      throw const TranslationOfflineException();
    }

    if (response.statusCode == 429 ||
        response.statusCode == 503 ||
        response.statusCode == 502) {
      throw const LibreRateLimitException();
    }

    if (response.statusCode != 200) {
      throw LibreNetworkException(response.statusCode);
    }

    final data = jsonDecode(response.body);

    final translated = data['translatedText'];
    if (translated == null || translated.toString().trim().isEmpty) {
      return text;
    }

    return translated.toString();
  }

  @override
  Future<List<String>> translateBatch(
    List<String> texts, {
    required String from,
    required String to,
  }) async {
    if (texts.isEmpty) return const [];

    final combined =
        texts.map((t) => t.trim().isEmpty ? '.' : t).join(_separator);

    final translatedCombined = await translate(
      combined,
      from: from,
      to: to,
    );

    final parts = translatedCombined.split(_separator);

    return List.generate(texts.length, (index) {
      if (index >= parts.length) return texts[index];

      final translated = parts[index].trim();
      return translated.isEmpty ? texts[index] : translated;
    });
  }

  @override
  void close() {
    _client.close();
  }
}