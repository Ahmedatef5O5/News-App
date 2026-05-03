import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/pagination/widgets/pagination_bar_widget.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/widgets/app_drawer.dart';
import 'package:news_app/core/widgets/custom_app_bar_icon.dart';
import 'package:news_app/features/home/widgets/home_carousel_section.dart';
import '../../../core/helpers/category_chips.dart';
import '../../../core/helpers/empty_state.dart';
import '../../../core/helpers/error_state.dart';
import '../../../core/helpers/shimmer_box.dart';
import '../../../core/pagination/model/pagination_meta.dart';
import '../../../core/pagination/widgets/load_more_footer.dart';
import '../../../core/widgets/article_card_widget.dart';
import '../Home_Cubit/home_cubit.dart';

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

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: BlocConsumer<HomeCubit, HomeState>(
        buildWhen: (prev, curr) =>
            prev.headlinesStatus != curr.headlinesStatus ||
            prev.recommendedStatus != curr.recommendedStatus ||
            prev.selectedCategory != curr.selectedCategory ||
            prev.isRefreshing != curr.isRefreshing ||
            prev.pagination != curr.pagination ||
            prev.recommended.length != curr.recommended.length,
        listenWhen: (prev, curr) =>
            prev.pagination.currentPage != curr.pagination.currentPage &&
            curr.recommendedStatus == PageLoadStatus.success,
        listener: (_, state) {
          if (state.recommendedStatus == PageLoadStatus.success &&
              state.pagination.currentPage > 1) {
            _scrollToTop();
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
            onRefresh: () => context.read<HomeCubit>().refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _HomeAppBar(),

                SliverToBoxAdapter(
                  child: CategoryChips(
                    selected: state.selectedCategory,
                    onSelected: (cat) =>
                        context.read<HomeCubit>().selectCategory(cat),
                  ),
                ),

                SliverToBoxAdapter(
                    child: _SectionHeader(
                  label: 'Breaking News',
                  accentColor: AppColors.accent,
                  onViewAll: () =>
                      Navigator.of(context).pushNamed(AppRoutes.headlinesRoute),
                )),

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

                SliverToBoxAdapter(
                    child: _SectionHeader(
                  label: 'For You',
                  accentColor: AppColors.primary,
                  trailing: state.showPaginationBar
                      ? _PageInfoBadge(pagination: state.pagination)
                      : null,
                  onViewAll: () {},
                  // onViewAll: () => Navigator.of(context)
                  // .pushNamed(AppRoutes.headlinesRoute),
                )),

                _RecommendedFeed(state: state),

                SliverToBoxAdapter(
                  child: _buildLoadMoreFooter(context, state),
                ),

                SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: state.showPaginationBar
                        ? PaginationBarWidget(
                            key: const ValueKey('pagination_bar'),
                            meta: state.pagination,
                            isLoading: state.recommendedStatus ==
                                PageLoadStatus.loadingPage,
                            onPageTap: (page) {
                              context.read<HomeCubit>().goToPage(page);
                              _scrollToTop();
                            },
                            onPrevious: () {
                              context.read<HomeCubit>().goToPreviousPage();
                              _scrollToTop();
                            },
                            onNext: () {
                              context.read<HomeCubit>().goToNextPage();
                              _scrollToTop();
                            },
                          )
                        : const SizedBox.shrink(key: ValueKey('no_bar')),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreFooter(BuildContext context, HomeState state) {
    final pag = state.pagination;
    return switch (state.recommendedStatus) {
      PageLoadStatus.loadingMore => const LoadMoreFooter(
          status: LoadMoreStatus.loading,
        ),
      PageLoadStatus.failure => LoadMoreFooter(
          status: LoadMoreStatus.error,
          onRetry: () => context.read<HomeCubit>().retryRecommended(),
        ),
      PageLoadStatus.success
          when pag.isLastPage && state.recommended.isNotEmpty =>
        const LoadMoreFooter(
          status: LoadMoreStatus.endOfList,
          isLastPage: true,
        ),
      _ => const LoadMoreFooter(status: LoadMoreStatus.idle),
    };
  }
}

// ── Feed Sliver ────────────────────────────────────────────────────────────────

class _RecommendedFeed extends StatelessWidget {
  const _RecommendedFeed({required this.state});
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

    // Page-jump loading overlay
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

    // Error state (initial)
    if (state.recommendedStatus == PageLoadStatus.failure &&
        state.recommended.isEmpty) {
      return SliverToBoxAdapter(
        child: ErrorState(
          message: state.recommendedError ?? 'Failed to load',
          onRetry: () => context.read<HomeCubit>().retryRecommended(),
        ),
      );
    }

    // Empty state
    if (state.recommended.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.article_outlined,
          title: 'No articles found',
          subtitle: 'Pull down to refresh',
        ),
      );
    }

    // Article list
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

// ── Shared UI sub-widgets ──────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceCard,
            ),
            child: const Icon(Icons.menu_rounded, size: 22),
          ),
        ),
      ),
      title: Text(
        'NewsWave',
        style: tt.headlineMedium?.copyWith(
          color: AppColors.primary,
          fontSize: 20,
        ),
      ),
      actions: [
        CustomAppBarIcon(
          icon: Icons.search_rounded,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.searchRoute),
        ),
        const SizedBox(width: 8),
        CustomAppBarIcon(
          icon: Icons.bookmark_outline_rounded,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.favoriteRoute),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.accentColor,
    this.onViewAll,
    this.trailing,
  });

  final String label;
  final Color accentColor;
  final VoidCallback? onViewAll;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: tt.headlineMedium?.copyWith(fontSize: 18),
          ),
          const Spacer(),
          if (trailing != null)
            trailing!
          else if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: const Text('View all'),
            ),
        ],
      ),
    );
  }
}

/// Small badge showing "Page X of Y" next to the section header.
class _PageInfoBadge extends StatelessWidget {
  const _PageInfoBadge({required this.pagination});
  final PaginationMeta pagination;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Page ${pagination.currentPage} of ${pagination.totalPages}',
        style: tt.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
