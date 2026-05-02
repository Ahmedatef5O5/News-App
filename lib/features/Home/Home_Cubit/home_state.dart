part of 'home_cubit.dart';

enum LoadStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final LoadStatus headlinesStatus;
  final LoadStatus recommendedStatus;
  final List<Article> headlines;
  final List<Article> recommended;
  final String? headlinesError;
  final String? recommendedError;
  final NewsCategory selectedCategory;
  final bool isRefreshing;

  const HomeState({
    this.headlinesStatus = LoadStatus.initial,
    this.recommendedStatus = LoadStatus.initial,
    this.headlines = const [],
    this.recommended = const [],
    this.headlinesError,
    this.recommendedError,
    this.selectedCategory = NewsCategory.general,
    this.isRefreshing = false,
  });

  HomeState copyWith({
    LoadStatus? headlinesStatus,
    LoadStatus? recommendedStatus,
    List<Article>? headlines,
    List<Article>? recommended,
    String? headlinesError,
    String? recommendedError,
    NewsCategory? selectedCategory,
    bool? isRefreshing,
  }) {
    return HomeState(
      headlinesStatus: headlinesStatus ?? this.headlinesStatus,
      recommendedStatus: recommendedStatus ?? this.recommendedStatus,
      headlines: headlines ?? this.headlines,
      recommended: recommended ?? this.recommended,
      headlinesError: headlinesError ?? this.headlinesError,
      recommendedError: recommendedError ?? this.recommendedError,
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
        selectedCategory,
        isRefreshing,
      ];
}
