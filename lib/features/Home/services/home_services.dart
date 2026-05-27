import 'package:dio/dio.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/models/news_api_response.dart';

class HomeServices {
  final Dio _dio;

  HomeServices({required Dio dio}) : _dio = dio;

  Future<NewsApiResponse> getTopHeadlines({
    String country = 'us',
    String? category,
    int page = 1,
    int pageSize = AppConstants.headlinesPageSize,
  }) async {
    final response = await _dio.get(
      AppConstants.topHeadlines,
      queryParameters: {
        'country': country,
        if (category != null) 'category': category,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return NewsApiResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<NewsApiResponse> getRecommended({
    String country = 'us',
    int page = 1,
    int pageSize = AppConstants.recommendedPageSize,
  }) async {
    final response = await _dio.get(
      AppConstants.topHeadlines,
      queryParameters: {
        'country': country,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return NewsApiResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
