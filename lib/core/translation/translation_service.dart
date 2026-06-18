import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  TranslationService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _base = 'https://api.mymemory.translated.net/get';

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
    return Future.wait(
      texts.map((t) => translate(t, from: from, to: to)),
    );
  }

  String _fixEntities(String s) => s
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
}
