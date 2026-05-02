part of 'search_cubit.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final String query;
  final List<Article> results;
  final int totalResults;
  final String? error;

  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.results = const [],
    this.totalResults = 0,
    this.error,
  });

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Article>? results,
    int? totalResults,
    String? error,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      totalResults: totalResults ?? this.totalResults,
      error: error,
    );
  }

  // to ensure if any change happen
  @override
  List<Object?> get props => [status, query, results, totalResults, error];
}
