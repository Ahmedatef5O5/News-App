import 'package:dio/dio.dart';
import 'package:news_app/core/models/news_api_response.dart';
import 'package:news_app/core/utilities/constants/app_constants.dart';
import 'package:retrofit/retrofit.dart';
part 'search_services_retrofit.g.dart';

@RestApi()
abstract class SearchServicesRetrofit {
  factory SearchServicesRetrofit(Dio dio, {String? baseUrl}) =
      _SearchServicesRetrofit;

  @GET(AppConstants.everything)
  Future<NewsApiResponse> search({
    @Query('q') required String q,
    @Query('page') int page = 1,
    @Query('pageSize') int pageSize = 15,
    @Query('searchIn') String searchIn = 'title',
    @Header('Authorization') required String apiKey,
  });
}
