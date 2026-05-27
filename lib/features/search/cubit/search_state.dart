part of 'search_cubit.dart';

enum SearchStatus {
  initial,
  loading,
  loadingMore,
  loadingPage,
  success,
  failure
}

class SearchState extends Equatable {
  final SearchStatus status;
  final String query;
  final List<Article> results;
  final PaginationMeta pagination;
  final String? error;

  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.results = const [],
    this.pagination = const PaginationMeta(
      pageSize: AppConstants.searchPageSize,
    ),
    this.error,
  });

  bool get isLoading =>
      status == SearchStatus.loading ||
      status == SearchStatus.loadingMore ||
      status == SearchStatus.loadingPage;

  bool get showPaginationBar =>
      status == SearchStatus.success && results.isNotEmpty;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Article>? results,
    PaginationMeta? pagination,
    int? totalResults,
    String? error,
    bool clearError = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      pagination: pagination ?? this.pagination,
      error: clearError ? null : (error ?? this.error),
    );
  }

  // to ensure if any change happen
  @override
  List<Object?> get props => [status, query, results, pagination, error];
}
