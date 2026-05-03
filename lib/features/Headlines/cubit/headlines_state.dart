part of 'headlines_cubit.dart';

enum HeadlinesPageLoadStatus { idle, loading, success, failure }

class HeadlinesState extends Equatable {
  /// ALL articles fetched for the current category (up to 100).
  /// We slice this list client-side — no extra network call per page.
  final List<Article> allArticles;

  /// The slice shown on the current page.
  final List<Article> pageArticles;

  final HeadlinesPageLoadStatus status;
  final String? error;
  final PaginationMeta pagination;
  final NewsCategory selectedCategory;

  const HeadlinesState({
    this.allArticles = const [],
    this.pageArticles = const [],
    this.status = HeadlinesPageLoadStatus.idle,
    this.error,
    this.pagination = const PaginationMeta(
      pageSize: AppConstants.headlinesPageSize,
    ),
    this.selectedCategory = NewsCategory.general,
  });

  bool get showPagination =>
      status == HeadlinesPageLoadStatus.success && allArticles.isNotEmpty;

  HeadlinesState copyWith({
    List<Article>? allArticles,
    List<Article>? pageArticles,
    HeadlinesPageLoadStatus? status,
    String? error,
    PaginationMeta? pagination,
    NewsCategory? selectedCategory,
    bool clearError = false,
  }) {
    return HeadlinesState(
      allArticles: allArticles ?? this.allArticles,
      pageArticles: pageArticles ?? this.pageArticles,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      pagination: pagination ?? this.pagination,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props =>
      [allArticles, pageArticles, status, error, pagination, selectedCategory];
}
