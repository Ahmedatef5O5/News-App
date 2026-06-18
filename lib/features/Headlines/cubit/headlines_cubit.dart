import 'dart:async';
import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/cubits/category_cubit.dart';
import 'package:news_app/core/models/article_model.dart';
import '../../../core/locale/locale_cubit.dart';
import '../../../core/pagination/model/pagination_meta.dart';
import '../../../core/repositories/home_repository.dart';

part 'headlines_state.dart';

class HeadlinesCubit extends Cubit<HeadlinesState> {
  HeadlinesCubit({
    required this.categoryCubit,
    required HomeRepository repository,
    required LocaleCubit localeCubit,
  })  : _repo = repository,
        _locale = localeCubit,
        super(const HeadlinesState()) {
    _syncCategory(categoryCubit.state);
    _categorySubscription = categoryCubit.stream.listen(_syncCategory);
    _localeSubscription = localeCubit.stream.listen(_onLocaleChanged);
  }

  final HomeRepository _repo;
  final LocaleCubit _locale;
  final CategoryCubit categoryCubit;
  late final StreamSubscription<NewsCategory> _categorySubscription;
  late final StreamSubscription<Locale> _localeSubscription;

  void _onLocaleChanged(Locale locale) {
    if (isClosed) return;
    _fetchAndShowPage(
      category: state.selectedCategory == NewsCategory.general
          ? null
          : state.selectedCategory.value,
      page: 1,
      forceRefresh: false,
    );
  }

  // ── Category sync ──────────────────────────────────────────────────────────

  void _syncCategory(NewsCategory category) {
    if (isClosed) return;
    emit(state.copyWith(
      selectedCategory: category,
      status: HeadlinesPageLoadStatus.loading,
      clearError: true,
    ));
    _fetchAndShowPage(
      category: category == NewsCategory.general ? null : category.value,
      page: 1,
    );
  }

  // ── Pagination ─────────────────────────────────────────────────────────────

  Future<void> goToPage(int page) async {
    if (page == state.pagination.currentPage) return;
    if (page < 1 || page > state.pagination.totalPages) return;
    // Client-side slice — no network call needed.
    _showPage(state.allArticles, page, fromCache: state.fromCache);
  }

  Future<void> goToNextPage() => goToPage(state.pagination.nextPage);
  Future<void> goToPreviousPage() => goToPage(state.pagination.previousPage);

  Future<void> refresh() => _fetchAndShowPage(
        category: state.selectedCategory == NewsCategory.general
            ? null
            : state.selectedCategory.value,
        page: 1,
        forceRefresh: true,
      );

  Future<void> retry() => _fetchAndShowPage(
        category: state.selectedCategory == NewsCategory.general
            ? null
            : state.selectedCategory.value,
        page: 1,
      );

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _fetchAndShowPage({
    required String? category,
    required int page,
    bool forceRefresh = false,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(
      status: HeadlinesPageLoadStatus.loading,
      clearError: true,
    ));
    try {
      final result = await _repo.getHeadlinesWithMeta(
          category: category,
          pageSize: AppConstants.maxApiResults,
          forceRefresh: forceRefresh,
          locale: _locale.state.languageCode);
      if (isClosed) return;
      _showPage(result.articles, page, fromCache: result.fromCache);
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: HeadlinesPageLoadStatus.failure,
        error: e.toString(),
      ));
    }
  }

  void _showPage(
    List<Article> allArticles,
    int page, {
    bool fromCache = false,
  }) {
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
      fromCache: fromCache, // ← drives OfflineBanner
      pagination: PaginationMeta(
        currentPage: page,
        totalResults: allArticles.length,
        pageSize: pageSize,
      ),
    ));
  }

  // ── Cleanup ────────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _categorySubscription.cancel();
    _localeSubscription.cancel();
    return super.close();
  }
}
