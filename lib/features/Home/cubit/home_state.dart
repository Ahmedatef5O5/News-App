part of 'home_cubit.dart';

sealed class HomeState {
  const HomeState();
}

final class HomeInitial extends HomeState {}

/// TopHeadlines States
final class TopHeadlinesLoading extends HomeState {}

final class TopHeadlinesSuccessLoaded extends HomeState {
  final List<Article>? articles;

  const TopHeadlinesSuccessLoaded(this.articles);
}

final class TopHeadlinesError extends HomeState {
  final String errMsg;

  const TopHeadlinesError(this.errMsg);
}

/// RecommendedNews States
final class RecommendedNewsLoading extends HomeState {}

final class RecommendedNewsLoaded extends HomeState {
  final List<Article>? articles;

  const RecommendedNewsLoaded(this.articles);
}

final class RecommendedNewsError extends HomeState {
  final String errMsg;

  const RecommendedNewsError(this.errMsg);
}
