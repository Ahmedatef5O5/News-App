import 'package:dio/dio.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/models/news_api_response.dart';
import '../domain/repositories/home_repository_contract.dart';

class HomeServices implements HomeRepositoryContract {
  final Dio _dio;

  HomeServices({required Dio dio}) : _dio = dio;

  @override
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

  @override
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

  @override
  Future<NewsApiResponse> getEverything({
    required String q,
    String language = 'ar',
    String sortBy = 'publishedAt',
    int page = 1,
    int pageSize = AppConstants.headlinesPageSize,
  }) async {
    final response = await _dio.get(
      AppConstants.everything,
      queryParameters: {
        'q': q,
        'language': language,
        'sortBy': sortBy,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return NewsApiResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
