import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/cubits/category_cubit.dart';
import '../../../core/models/article_model.dart';
import '../../../core/pagination/model/pagination_meta.dart';
import '../../../core/repositories/home_repository.dart';
part 'headlines_state.dart';

class HeadlinesCubit extends Cubit<HeadlinesState> {
  final HomeRepository _repo;

  final CategoryCubit categoryCubit;
  late final StreamSubscription _categorySubscription;

  HeadlinesCubit({required this.categoryCubit, HomeRepository? repository})
      : _repo = repository ?? HomeRepository(),
        super(const HeadlinesState()) {
    _syncCategory(categoryCubit.state);

    _categorySubscription = categoryCubit.stream.listen((category) {
      _syncCategory(category);
    });
  }

  void _syncCategory(NewsCategory category) {
    emit(state.copyWith(
      selectedCategory: category,
      status: HeadlinesPageLoadStatus.loading,
      clearError: true,
    ));
    _fetchAndShowPage(
        category: category == NewsCategory.general ? null : category.value,
        page: 1);
  }

  Future<void> goToPage(int page) async {
    if (page == state.pagination.currentPage) return;
    if (page < 1 || page > state.pagination.totalPages) return;
    _showPage(state.allArticles, page);
  }

  Future<void> goToNextPage() => goToPage(state.pagination.nextPage);
  Future<void> goToPreviousPage() => goToPage(state.pagination.previousPage);

  Future<void> retry() => _fetchAndShowPage(
        category: state.selectedCategory == NewsCategory.general
            ? null
            : state.selectedCategory.value,
        page: 1,
      );

  Future<void> _fetchAndShowPage({
    required String? category,
    required int page,
  }) async {
    emit(state.copyWith(
      status: HeadlinesPageLoadStatus.loading,
      clearError: true,
    ));

    try {
      final articles = await _repo.getHeadlines(
        category: category,
        pageSize: AppConstants.maxApiResults,
        forceRefresh: true,
      );
      _showPage(articles, page);
    } catch (e) {
      emit(state.copyWith(
        status: HeadlinesPageLoadStatus.failure,
        error: e.toString(),
      ));
    }
  }

  void _showPage(List<Article> allArticles, int page) {
    final pageSize = AppConstants.headlinesPageSize;
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, allArticles.length);
    final slice = start < allArticles.length
        ? allArticles.sublist(start, end)
        : <Article>[];

    emit(state.copyWith(
      allArticles: allArticles,
      pageArticles: slice,
      status: HeadlinesPageLoadStatus.success,
      pagination: PaginationMeta(
        currentPage: page,
        totalResults: allArticles.length,
        pageSize: pageSize,
      ),
    ));
  }

  @override
  Future<void> close() {
    _categorySubscription.cancel();
    return super.close();
  }
}
