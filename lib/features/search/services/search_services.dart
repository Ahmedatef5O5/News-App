import 'package:dio/dio.dart';
import 'package:news_app/core/utilities/constants/app_constants.dart';
import '../../Home/models/top_headlines_api_response.dart';
import '../models/search_body.dart';

class SearchServices {
  final aDio = Dio();
  Future<TopHeadlinesApiResponse> search(SearchBody body) async {
    try {
      aDio.options.baseUrl = AppConstants.baseUrl;
      final headers = {'Authorization': "Bearer ${AppConstants.apiKey}"};
      final response = await aDio.get(
        AppConstants.everything,
        queryParameters: body.toMap(),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return TopHeadlinesApiResponse.fromMap(response.data);
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
