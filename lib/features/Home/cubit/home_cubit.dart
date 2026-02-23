import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/features/Home/models/top_headlines_api_response.dart';
import 'package:news_app/features/Home/models/top_headlines_body.dart';
import 'package:news_app/features/Home/services/home_services.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final homeServices = HomeServices();

  Future<void> getTopHeadlines() async {
    emit(TopHeadlinesLoading());
    try {
      const body = TopHeadlinesBody(
        category: 'business',
        page: 1,
        pageSize: 10,
      );
      final result = await homeServices.getTopHeadlines(body);
      emit(TopHeadlinesSuccessLoaded(result.articles));
    } catch (e) {
      emit(TopHeadlinesError(e.toString()));
    }
  }
}
