import 'package:dio/dio.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/models/news_api_response.dart';

import '../../../core/exceptions/news_exceptions.dart';

/// Network service for the /v2/everything (search) endpoint.
class SearchService {
  final Dio _dio;
  SearchService({required Dio dio}) : _dio = dio;

  Future<NewsApiResponse> search({
    required String query,
    String searchIn = 'title',
    String? language,
    int page = 1,
    int pageSize = AppConstants.searchPageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'searchIn': searchIn,
        'page': page,
        'pageSize': pageSize,
      };

      if (language != null && language.isNotEmpty) {
        queryParams['language'] = language;
      }

      final response = await _dio.get(
        AppConstants.everything,
        queryParameters: queryParams,
      );

      return NewsApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
