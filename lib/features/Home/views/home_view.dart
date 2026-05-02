import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/widgets/app_drawer.dart';
import '../../../core/helpers/category_chips.dart';
import '../../../core/helpers/empty_state.dart';
import '../../../core/helpers/error_state.dart';
import '../../../core/helpers/shimmer_box.dart';
import '../../../core/widgets/article_card_widget.dart';
import '../Home_Cubit/home_cubit.dart';
import '../widgets/home_carousel_section.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit()..init(),
      child: const _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const AppDrawer(),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
            onRefresh: () => context.read<HomeCubit>().refresh(),
            child: CustomScrollView(
              slivers: [
                // ── SliverAppBar ─────────────────────────────────────────
                _AppBar(),

                // ── Category Chips ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: CategoryChips(
                    selected: state.selectedCategory,
                    onSelected: (cat) =>
                        context.read<HomeCubit>().selectCategory(cat),
                  ),
                ),

                // ── Breaking News Label ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Breaking News',
                          style: tt.headlineMedium?.copyWith(fontSize: 18),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Headlines Carousel ───────────────────────────────────
                SliverToBoxAdapter(
                  child: HomeCarouselSection(
                    status: state.headlinesStatus,
                    articles: state.headlines,
                    error: state.headlinesError,
                    onRetry: () => context
                        .read<HomeCubit>()
                        .fetchHeadlines(forceRefresh: true),
                    onTap: (article) => Navigator.of(context).pushNamed(
                      AppRoutes.artcileDetailsRoute,
                      arguments: article,
                    ),
                  ),
                ),

                // ── Recommended Label ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'For You',
                          style: tt.headlineMedium?.copyWith(fontSize: 18),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Recommended Articles ─────────────────────────────────
                _RecommendedSection(state: state),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 64,
      leading: Builder(
        builder: (ctx) => GestureDetector(
          onTap: () => Scaffold.of(ctx).openDrawer(),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceCard,
            ),
            child: const Icon(Icons.menu_rounded, size: 22),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NewsWave',
            style: tt.headlineMedium?.copyWith(
              color: AppColors.primary,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.searchRoute),
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceCard,
            ),
            child: const Icon(Icons.search_rounded, size: 22),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.favoriteRoute),
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceCard,
            ),
            child: const Icon(Icons.bookmark_outline_rounded, size: 22),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection({required this.state});
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    if (state.recommendedStatus == LoadStatus.loading) {
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

    if (state.recommendedStatus == LoadStatus.failure) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          message: state.recommendedError ?? 'Failed to load articles',
          onRetry: () =>
              context.read<HomeCubit>().fetchRecommended(forceRefresh: true),
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
