import 'package:http/http.dart' as http;
import 'package:news_app/core/translation/translation_exceptions.dart';
import 'dart:convert';
import 'package:news_app/core/translation/translation_service.dart';

class MyMemoryTranslationService implements TranslationService {
  MyMemoryTranslationService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  static const _base = 'https://api.mymemory.translated.net/get';
  static const _separator = '\n<<<SEP>>>\n';

  @override
  Future<String> translate(String text,
      {required String from, required String to}) async {
    if (text.trim().isEmpty) return text;

    final uri =
        Uri.parse('$_base?q=${Uri.encodeComponent(text)}&langpair=$from|$to');
    final res = await _client.get(uri);

    if (res.statusCode == 429) {
      throw const TranslationRateLimitException();
    }
    if (res.statusCode != 200) {
      throw TranslationNetworkException(res.statusCode);
    }

    final data = jsonDecode(res.body);

    if (data['responseStatus'] != 200) {
      throw TranslationNetworkException(data['responseStatus']);
    }

    if (data['responseStatus'] == 429) {
      throw const TranslationRateLimitException();
    }

    return data['responseData']['translatedText'] ?? text;
  }

  @override
  Future<List<String>> translateBatch(
    List<String> texts, {
    required String from,
    required String to,
  }) async {
    final combined =
        texts.map((t) => t.trim().isEmpty ? '.' : t).join(_separator);

    final result = await translate(combined, from: from, to: to);
    final parts = result.split(_separator);

    return List.generate(texts.length, (i) {
      final translated = i < parts.length ? parts[i].trim() : '';
      return translated.isEmpty ? texts[i] : translated;
    });
  }

  @override
  void close() => _client.close();
}
