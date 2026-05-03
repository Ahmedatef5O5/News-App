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
  /// HeadLines  status
  final LoadStatus headlinesStatus;
  final List<Article> headlines;
  final String? headlinesError;

  /// Recommended status
  final PageLoadStatus recommendedStatus;
  final List<Article> recommended;
  final String? recommendedError;
  final PaginationMeta pagination;

  // global
  final NewsCategory selectedCategory;
  final bool isRefreshing;

  const HomeState({
    this.headlinesStatus = LoadStatus.initial,
    this.headlines = const [],
    this.headlinesError,
    this.recommendedStatus = PageLoadStatus.idle,
    this.recommended = const [],
    this.recommendedError,
    this.pagination = const PaginationMeta(),
    this.selectedCategory = NewsCategory.general,
    this.isRefreshing = false,
  });

  bool get isRecommendedLoading =>
      recommendedStatus == PageLoadStatus.loadingInitial ||
      recommendedStatus == PageLoadStatus.loadingMore ||
      recommendedStatus == PageLoadStatus.loadingPage;

  bool get showPaginationBar =>
      recommendedStatus == PageLoadStatus.success && recommended.isNotEmpty;

  HomeState copyWith({
    LoadStatus? headlinesStatus,
    List<Article>? headlines,
    String? headlinesError,
    PageLoadStatus? recommendedStatus,
    List<Article>? recommended,
    String? recommendedError,
    PaginationMeta? pagination,
    NewsCategory? selectedCategory,
    bool? isRefreshing,
    bool clearRecommendedError = false,
    bool clearHeadlinesError = false,
  }) {
    return HomeState(
      headlinesStatus: headlinesStatus ?? this.headlinesStatus,
      headlines: headlines ?? this.headlines,
      headlinesError: headlinesError ?? this.headlinesError,
      recommendedStatus: recommendedStatus ?? this.recommendedStatus,
      recommended: recommended ?? this.recommended,
      recommendedError: recommendedError ?? this.recommendedError,
      pagination: pagination ?? this.pagination,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

// to ensure if any change happend to rebuild state
  @override
  List<Object?> get props => [
        headlinesStatus,
        recommendedStatus,
        headlines,
        recommended,
        headlinesError,
        recommendedError,
        pagination,
        selectedCategory,
        isRefreshing,
      ];
}
