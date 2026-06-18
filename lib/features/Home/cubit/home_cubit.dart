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
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.categoryCubit,
    required HomeRepository repository,
    required LocaleCubit localeCubit,
  })  : _repo = repository,
        _locale = localeCubit,
        super(const HomeState()) {
    _syncCategory(categoryCubit.state);
    _categorySubscription = categoryCubit.stream.listen(_syncCategory);
    _localeSubscription = localeCubit.stream.listen(_onLocaleChanged);
  }

  final HomeRepository _repo;
  final LocaleCubit _locale;
  final CategoryCubit categoryCubit;
  late final StreamSubscription<NewsCategory> _categorySubscription;
  late final StreamSubscription<Locale> _localeSubscription;
  bool _initialized = false;

  void _onLocaleChanged(Locale locale) {
    if (isClosed) return;
    fetchHeadlines(forceRefresh: false);
    _loadPage(state.currentPage,
        mode: PageLoadStatus.loadingInitial, forceRefresh: false);
  }

  // ── Category sync ──────────────────────────────────────────────────────────

  void _syncCategory(NewsCategory category) {
    if (isClosed) return;
    if (!_initialized) return;
    emit(state.copyWith(
      selectedCategory: category,
      headlinesStatus: LoadStatus.loading,
      clearHeadlinesError: true,
    ));
    fetchHeadlines(
      category: category == NewsCategory.general ? null : category.value,
      forceRefresh: true,
    );
  }

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized || isClosed) return;
    _initialized = true;
    await Future.wait([
      fetchHeadlines(),
      _loadPage(1, mode: PageLoadStatus.loadingInitial),
    ]);
  }

  // ── Pull-to-refresh ────────────────────────────────────────────────────────

  Future<void> refresh() async {
    if (isClosed) return;
    emit(state.copyWith(isRefreshing: true));
    await Future.wait([
      fetchHeadlines(forceRefresh: true),
      _loadPage(1, mode: PageLoadStatus.loadingInitial, forceRefresh: true),
    ]);
    if (!isClosed) emit(state.copyWith(isRefreshing: false));
  }

  // ── Headlines ──────────────────────────────────────────────────────────────

  Future<void> fetchHeadlines({
    String? category,
    bool forceRefresh = false,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(
      headlinesStatus: LoadStatus.loading,
      clearHeadlinesError: true,
    ));
    try {
      final articles = await _repo.getHeadlines(
        category: category,
        forceRefresh: forceRefresh,
        locale: _locale.languageCode,
      );
      if (isClosed) return;
      emit(state.copyWith(
        headlinesStatus: LoadStatus.success,
        headlines: articles,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        headlinesStatus: LoadStatus.failure,
        headlinesError: e.toString(),
      ));
    }
  }

  // ── Recommended pages ──────────────────────────────────────────────────────

  Future<void> _loadPage(
    int page, {
    required PageLoadStatus mode,
    bool forceRefresh = false,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(pageStatus: mode, clearPageError: true));
    try {
      final result = await _repo.getRecommendedPage(
        page: page,
        forceRefresh: forceRefresh,
        locale: _locale.languageCode,
      );
      if (isClosed) return;
      emit(state.copyWith(
        pageStatus: PageLoadStatus.success,
        recommendedArticles: result.articles,
        totalRecommended: result.totalResults,
        currentPage: page,
        fromCache: result.fromCache,
        pagination: PaginationMeta(
          currentPage: page,
          totalResults: result.totalResults,
          pageSize: AppConstants.recommendedPageSize,
        ),
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        pageStatus: PageLoadStatus.failure,
        pageError: e.toString(),
      ));
    }
  }

  Future<void> goToPage(int page) =>
      _loadPage(page, mode: PageLoadStatus.loadingPage);

  Future<void> goToNextPage() => goToPage(state.pagination.nextPage);
  Future<void> goToPreviousPage() => goToPage(state.pagination.previousPage);

  // ── Cleanup ────────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _categorySubscription.cancel();
    _localeSubscription.cancel();
    return super.close();
  }
}
