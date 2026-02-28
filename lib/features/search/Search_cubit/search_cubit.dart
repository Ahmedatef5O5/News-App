import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/features/search/models/search_body.dart';
import 'package:news_app/features/search/services/search_services.dart';
import '../../../core/models/article_model.dart';
import '../../../core/utilities/constants/app_constants.dart';
import '../services/search_services_retrofit.dart';
part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  final searchServices = SearchServices();
  final searchServicesRetrofit = SearchServicesRetrofit(
    Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        // headers: {'Authorization': "Bearer ${AppConstants.apiKey}"},
      ),
    ),
  );

  Future<void> search(String keyword) async {
    emit(SearchResultsLoading());
    try {
      final body = SearchBody(q: keyword);
      // final response = await searchServices.search(body);
      final response = await searchServicesRetrofit.search(
        q: body.q,
        page: body.page,
        pageSize: body.pageSize,
        searchIn: body.searchIn,
        apiKey: 'Bearer ${AppConstants.apiKey}',
      );
      emit(SearchResultsSuccessLoaded(response.articles ?? []));
    } catch (e) {
      emit(SearchResultsError(e.toString()));
    }
  }
}
