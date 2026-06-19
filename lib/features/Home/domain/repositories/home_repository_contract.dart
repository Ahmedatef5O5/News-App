import '../../../../core/models/news_api_response.dart';

abstract class HomeRepositoryContract {
  Future<NewsApiResponse> getTopHeadlines({
    String country,
    String? category,
    int pageSize,
  });

  Future<NewsApiResponse> getEverything({required String q, int pageSize});

  Future<NewsApiResponse> getRecommended({String country, int page});
}
