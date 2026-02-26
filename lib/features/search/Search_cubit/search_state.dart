part of 'search_cubit.dart';

sealed class SearchState {
  const SearchState();
}

final class SearchInitial extends SearchState {}

final class SearchResultsLoading extends SearchState {}

final class SearchResultsSuccessLoaded extends SearchState {
  final List<Article> articles;
  const SearchResultsSuccessLoaded(this.articles);
}

final class SearchResultsError extends SearchState {
  final String errMsg;
  const SearchResultsError(this.errMsg);
}

// final class Searching extends SearchState {}
