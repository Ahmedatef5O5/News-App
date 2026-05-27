import 'package:dio/dio.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/models/news_api_response.dart';

/// Network service for the /v2/everything (search) endpoint.
class SearchService {
  final Dio _dio;
  SearchService({required Dio dio}) : _dio = dio;

  Future<NewsApiResponse> search({
    required String query,
    String searchIn = 'title',
    int page = 1,
    int pageSize = AppConstants.searchPageSize,
  }) async {
    final response = await _dio.get(
      AppConstants.everything,
      queryParameters: {
        'q': query,
        'searchIn': searchIn,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return NewsApiResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
