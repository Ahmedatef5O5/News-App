import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  TranslationService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  void close() => _client.close();

  static const _base = 'https://api.mymemory.translated.net/get';

  static const _separator = '\n<<<SEP>>>\n';

  Future<String> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    if (text.trim().isEmpty) return text;

    final uri = Uri.parse(_base).replace(queryParameters: {
      'q': text,
      'langpair': '$from|$to',
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      return text;
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final translated = json['responseData']['translatedText'] as String;
    return _fixEntities(translated);
  }

  Future<List<String>> translateBatch(
    List<String> texts, {
    required String from,
    required String to,
  }) async {
    final combined =
        texts.map((t) => t.trim().isEmpty ? '' : t).join(_separator);
    final result = await translate(combined, from: from, to: to);
    final parts = result.split(_separator);

    return List.generate(texts.length, (i) {
      final translated = i < parts.length ? parts[i] : '';
      return translated.isEmpty ? texts[i] : translated;
    });
  }

  String _fixEntities(String s) => s
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
}
