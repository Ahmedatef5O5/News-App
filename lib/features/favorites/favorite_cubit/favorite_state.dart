part of 'favorite_cubit.dart';

@immutable
sealed class FavoriteState {
  const FavoriteState();
}

final class FavoriteInitial extends FavoriteState {}

final class FavoriteLoading extends FavoriteState {}

final class FavoriteLoaded extends FavoriteState {
  final List<Article> articles;

  const FavoriteLoaded(this.articles);
}

final class FavoriteError extends FavoriteState {
  final String errMsg;

  const FavoriteError(this.errMsg);
}
