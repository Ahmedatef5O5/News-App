import 'package:dio/dio.dart';
import 'package:news_app/core/utilities/constants/app_constants.dart';
import 'package:news_app/features/Home/models/top_headlines_api_response.dart';
import 'package:news_app/features/Home/models/top_headlines_body.dart';

class HomeServices {
  final aDio = Dio();

  Future getTopHeadlines(TopHeadlinesBody body) async {
    try {
      aDio.options.baseUrl = AppConstants.baseUrl;
      final header = {'Authorization': 'Bearer ${AppConstants.apiKey}'};
      final response = await aDio.get(
        AppConstants.topHeadlines,
        // '${AppConstants.apiKey}${AppConstants.topHeadlines}',
        queryParameters: body.toMap(),
        options: Options(headers: header),
      );
      if (response.statusCode == 200) {
        return TopHeadlinesApiResponse.fromMap(response.data);
      }
    } catch (e) {
      rethrow;
    }
  }
}
