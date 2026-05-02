import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/article_model.dart';
import '../../../core/repositories/home_repository.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({HomeRepository? repository})
      : _repo = repository ?? HomeRepository(),
        super(const HomeState());

  final HomeRepository _repo;

  /// Fetches both sections on initial load.
  Future<void> init() async {
    await Future.wait([
      fetchHeadlines(),
      fetchRecommended(),
    ]);
  }

  /// Pull-to-refresh — forces network calls.
  Future<void> refresh() async {
    emit(state.copyWith(isRefreshing: true));
    await Future.wait([
      fetchHeadlines(forceRefresh: true),
      fetchRecommended(forceRefresh: true),
    ]);
    emit(state.copyWith(isRefreshing: false));
  }

  /// Select a category chip and reload headlines.
  Future<void> selectCategory(NewsCategory category) async {
    if (state.selectedCategory == category) return;
    emit(state.copyWith(
        selectedCategory: category, headlinesStatus: LoadStatus.loading));
    await fetchHeadlines(
      category: category == NewsCategory.general ? null : category.value,
      forceRefresh: true,
    );
  }

  Future<void> fetchHeadlines({
    String? category,
    bool forceRefresh = false,
  }) async {
    if (state.headlinesStatus == LoadStatus.loading && !forceRefresh) return;
    emit(state.copyWith(
        headlinesStatus: LoadStatus.loading, headlinesError: null));

    try {
      final articles = await _repo.getHeadlines(
        category: category,
        forceRefresh: forceRefresh,
      );
      emit(state.copyWith(
        headlinesStatus: LoadStatus.success,
        headlines: articles,
      ));
    } catch (e) {
      emit(state.copyWith(
        headlinesStatus: LoadStatus.failure,
        headlinesError: e.toString(),
      ));
    }
  }

  Future<void> fetchRecommended({
    bool forceRefresh = false,
  }) async {
    if (state.recommendedStatus == LoadStatus.loading && !forceRefresh) return;
    emit(state.copyWith(
        recommendedStatus: LoadStatus.loading, recommendedError: null));

    try {
      final articles = await _repo.getRecommended(forceRefresh: forceRefresh);
      emit(state.copyWith(
        recommendedStatus: LoadStatus.success,
        recommended: articles,
      ));
    } catch (e) {
      emit(state.copyWith(
        recommendedStatus: LoadStatus.failure,
        recommendedError: e.toString(),
      ));
    }
  }
}
