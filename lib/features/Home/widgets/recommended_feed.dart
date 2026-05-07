import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/helpers/empty_state.dart';
import '../../../core/helpers/error_state.dart';
import '../../../core/helpers/shimmer_box.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/article_card_widget.dart';
import '../cubit/home_cubit.dart';

class RecommendedFeed extends StatelessWidget {
  const RecommendedFeed({super.key, required this.state});
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    // Initial load skeleton
    if (state.recommendedStatus == PageLoadStatus.loadingInitial) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const ArticleCardSkeleton(),
            childCount: 5,
          ),
        ),
      );
    }

    if (state.recommendedStatus == PageLoadStatus.loadingPage) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const ArticleCardSkeleton(),
            childCount: AppConstants.recommendedPageSize,
          ),
        ),
      );
    }

    if (state.recommendedStatus == PageLoadStatus.failure &&
        state.recommended.isEmpty) {
      return SliverToBoxAdapter(
        child: ErrorState(
          message: state.recommendedError ?? 'Failed to load',
          onRetry: () => context.read<HomeCubit>().retryRecommended(),
        ),
      );
    }

    if (state.recommended.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.article_outlined,
          title: 'No articles found',
          subtitle: 'Pull down to refresh',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, index) {
            final article = state.recommended[index];
            return ArticleCard(
              article: article,
              onTap: () => Navigator.of(ctx).pushNamed(
                AppRoutes.artcileDetailsRoute,
                arguments: article,
              ),
            );
          },
          childCount: state.recommended.length,
        ),
      ),
    );
  }
}
