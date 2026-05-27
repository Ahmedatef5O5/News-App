part of 'home_cubit.dart';

enum LoadStatus { initial, loading, success, failure }

enum PageLoadStatus {
  idle,
  loadingInitial,
  loadingMore,
  loadingPage,
  success,
  failure,
}

class HomeState extends Equatable {
  // ── Headlines ──────────────────────────────────────────────────────────────
  final LoadStatus headlinesStatus;
  final List<Article> headlines;
  final String? headlinesError;

  // ── Recommended (paginated) ────────────────────────────────────────────────
  final PageLoadStatus pageStatus;
  final List<Article> recommendedArticles;
  final String? pageError;
  final PaginationMeta pagination;
  final int currentPage;
  final int totalRecommended;

  // ── Global ─────────────────────────────────────────────────────────────────
  final NewsCategory selectedCategory;
  final bool isRefreshing;
  final bool fromCache;

  const HomeState({
    this.headlinesStatus = LoadStatus.initial,
    this.headlines = const [],
    this.headlinesError,
    this.pageStatus = PageLoadStatus.idle,
    this.recommendedArticles = const [],
    this.pageError,
    this.pagination = const PaginationMeta(),
    this.currentPage = 1,
    this.totalRecommended = 0,
    this.selectedCategory = NewsCategory.general,
    this.isRefreshing = false,
    this.fromCache = false,
  });

  // ── Convenience getters ────────────────────────────────────────────────────

  bool get isRecommendedLoading =>
      pageStatus == PageLoadStatus.loadingInitial ||
      pageStatus == PageLoadStatus.loadingPage;

  bool get showPaginationBar =>
      pageStatus == PageLoadStatus.success && recommendedArticles.isNotEmpty;

  // ── copyWith ───────────────────────────────────────────────────────────────

  HomeState copyWith({
    LoadStatus? headlinesStatus,
    List<Article>? headlines,
    String? headlinesError,
    PageLoadStatus? pageStatus,
    List<Article>? recommendedArticles,
    String? pageError,
    PaginationMeta? pagination,
    int? currentPage,
    int? totalRecommended,
    NewsCategory? selectedCategory,
    bool? isRefreshing,
    bool? fromCache,
    bool clearHeadlinesError = false,
    bool clearPageError = false,
  }) {
    return HomeState(
      headlinesStatus: headlinesStatus ?? this.headlinesStatus,
      headlines: headlines ?? this.headlines,
      headlinesError:
          clearHeadlinesError ? null : (headlinesError ?? this.headlinesError),
      pageStatus: pageStatus ?? this.pageStatus,
      recommendedArticles: recommendedArticles ?? this.recommendedArticles,
      pageError: clearPageError ? null : (pageError ?? this.pageError),
      pagination: pagination ?? this.pagination,
      currentPage: currentPage ?? this.currentPage,
      totalRecommended: totalRecommended ?? this.totalRecommended,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      fromCache: fromCache ?? this.fromCache,
    );
  }

  @override
  List<Object?> get props => [
        headlinesStatus,
        headlines,
        headlinesError,
        pageStatus,
        recommendedArticles,
        pageError,
        pagination,
        currentPage,
        totalRecommended,
        selectedCategory,
        isRefreshing,
        fromCache,
      ];
}
