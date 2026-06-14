import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/helpers/empty_state.dart';
import '../../../core/helpers/error_state.dart';
import '../../../core/helpers/shimmer_box.dart';
import '../../../core/models/article_detail_args.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/article_card_widget.dart';
import '../cubit/home_cubit.dart';

class RecommendedFeed extends StatelessWidget {
  const RecommendedFeed({super.key, required this.state});
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (state.pageStatus == PageLoadStatus.loadingInitial ||
        state.pageStatus == PageLoadStatus.idle) {
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

    // Page-change skeleton
    if (state.pageStatus == PageLoadStatus.loadingPage) {
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

    // Full-page error
    if (state.pageStatus == PageLoadStatus.failure &&
        state.recommendedArticles.isEmpty) {
      return SliverToBoxAdapter(
        child: ErrorState(
          message: state.pageError ?? l10n.failedToLoad,
          onRetry: () => context.read<HomeCubit>().goToPage(state.currentPage),
        ),
      );
    }

    // Empty state
    if (state.recommendedArticles.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.article_outlined,
          title: l10n.noArticlesFound,
          subtitle: l10n.pullDownToRefresh,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, index) {
            final article = state.recommendedArticles[index];
            const heroContext = 'recommended';
            final heroTag = 'article-image-${article.uniqueId}-$heroContext';
            return ArticleCard(
              article: article,
              heroContext: heroContext,
              onTap: () => Navigator.of(ctx).pushNamed(
                AppRoutes.artcileDetailsRoute,
                arguments:
                    ArticleDetailArgs(article: article, heroTag: heroTag),
              ),
            );
          },
          childCount: state.recommendedArticles.length,
        ),
      ),
    );
  }
}
