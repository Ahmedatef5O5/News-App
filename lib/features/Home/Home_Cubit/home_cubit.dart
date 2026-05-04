import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/cubits/category_cubit.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/article_model.dart';
import '../../../core/pagination/model/pagination_meta.dart';
import '../../../core/repositories/home_repository.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repo;

  final CategoryCubit categoryCubit;
  late final StreamSubscription _categorySubscription;

  HomeCubit({required this.categoryCubit, HomeRepository? repository})
      : _repo = repository ?? HomeRepository(),
        super(const HomeState()) {
    _syncCategory(categoryCubit.state);

    _categorySubscription = categoryCubit.stream.listen((category) {
      _syncCategory(category);
    });
  }

  void _syncCategory(NewsCategory category) {
    emit(state.copyWith(
      selectedCategory: category,
      headlinesStatus: LoadStatus.loading,
    ));

    fetchHeadlines(
        category: category == NewsCategory.general ? null : category.value,
        forceRefresh: true);
  }

  /// Fetches both sections on initial load.
  Future<void> init() async {
    await Future.wait([
      fetchHeadlines(),
      // fetchRecommended(),
      _loadPage(1, mode: PageLoadStatus.loadingInitial),
    ]);
  }

  /// Pull-to-refresh — forces network calls.
  Future<void> refresh() async {
    emit(state.copyWith(isRefreshing: true));
    await _repo.clearRecommendedCache();
    await Future.wait([
      fetchHeadlines(forceRefresh: true),
      _loadPage(1, mode: PageLoadStatus.loadingInitial, forceRefresh: true),
    ]);
    emit(state.copyWith(isRefreshing: false));
  }

  Future<void> fetchHeadlines({
    String? category,
    bool forceRefresh = false,
  }) async {
    emit(state.copyWith(
      headlinesStatus: LoadStatus.loading,
      clearHeadlinesError: true,
    ));
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

  Future<void> loadNextPage() async {
    final pag = state.pagination;
    if (!pag.hasNextPage) return;
    if (state.recommendedStatus == PageLoadStatus.loadingMore) return;

    final nextPage = pag.nextPage;
    await _loadPage(nextPage, mode: PageLoadStatus.loadingMore);
  }

  Future<void> goToPage(int page) async {
    if (page == state.pagination.currentPage) return;
    if (page < 1 || page > state.pagination.totalPages) return;

    await _loadPage(page, mode: PageLoadStatus.loadingPage);
  }

  Future<void> goToNextPage() => goToPage(state.pagination.nextPage);
  Future<void> goToPreviousPage() => goToPage(state.pagination.previousPage);

  Future<void> retryRecommended() async {
    await _loadPage(
      state.pagination.currentPage,
      mode: PageLoadStatus.loadingInitial,
      forceRefresh: true,
    );
  }

  Future<void> _loadPage(
    int page, {
    required PageLoadStatus mode,
    bool forceRefresh = false,
  }) async {
    emit(state.copyWith(
      recommendedStatus: mode,
      clearRecommendedError: true,
    ));

    try {
      final result = await _repo.getRecommendedPage(
        page: page,
        forceRefresh: forceRefresh,
      );

      final newPagination = state.pagination.copyWith(
        currentPage: page,
        totalResults: result.totalResults,
        pageSize: AppConstants.recommendedPageSize,
      );

      List<Article> updatedList;
      if (mode == PageLoadStatus.loadingMore) {
        // Append — deduplicate by uniqueId to prevent duplicates
        final existingIds = state.recommended.map((a) => a.uniqueId).toSet();
        final newArticles = result.articles
            .where((a) => !existingIds.contains(a.uniqueId))
            .toList();
        updatedList = [...state.recommended, ...newArticles];
      } else {
        updatedList = result.articles;
      }

      emit(state.copyWith(
        recommendedStatus: PageLoadStatus.success,
        recommended: updatedList,
        pagination: newPagination,
      ));
    } catch (e) {
      emit(state.copyWith(
        recommendedStatus: PageLoadStatus.failure,
        recommendedError: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _categorySubscription.cancel();
    return super.close();
  }
}
