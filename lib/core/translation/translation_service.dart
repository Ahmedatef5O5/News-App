abstract class TranslationService {
  Future<String> translate(String text,
      {required String from, required String to});
  Future<List<String>> translateBatch(List<String> texts,
      {required String from, required String to});
  void close();
}
