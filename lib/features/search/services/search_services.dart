import 'package:dio/dio.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/models/news_api_response.dart';
import 'package:news_app/core/network/dio_client.dart';

class SearchService {
  final Dio _dio = DioClient.instance.dio;

  Future<NewsApiResponse> search({
    required String query,
    String searchIn = 'title',
    int page = 1,
    int pageSize = AppConstants.pageSize,
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
