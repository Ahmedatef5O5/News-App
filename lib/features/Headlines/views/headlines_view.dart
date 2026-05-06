import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/pagination/widgets/pagination_bar_widget.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/theme/app_colors.dart';
import '../../../core/cubits/category_cubit.dart';
import '../../../core/helpers/empty_state.dart';
import '../../../core/helpers/error_state.dart';
import '../../../core/helpers/shimmer_box.dart';
import '../../../core/widgets/article_card_widget.dart';
import '../../../core/widgets/custom_app_bar_icon.dart';
import '../cubit/headlines_cubit.dart';
import '../widgets/glass_category_row.dart';

class HeadlinesView extends StatelessWidget {
  const HeadlinesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HeadlinesCubit(
        categoryCubit: context.read<CategoryCubit>(),
      ),
      child: const _HeadlinesContent(),
    );
  }
}

class _HeadlinesContent extends StatefulWidget {
  const _HeadlinesContent();

  @override
  State<_HeadlinesContent> createState() => _HeadlinesContentState();
}

class _HeadlinesContentState extends State<_HeadlinesContent> {
  final ScrollController _scrollController = ScrollController();

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: BlocConsumer<HeadlinesCubit, HeadlinesState>(
        listenWhen: (prev, curr) =>
            prev.pagination.currentPage != curr.pagination.currentPage,
        listener: (_, __) => _scrollToTop(),
        builder: (context, state) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: colors.surface,
                leadingWidth: 42,
                automaticallyImplyLeading: false,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CustomAppBarIcon(
                    icon: CupertinoIcons.chevron_back,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
                title: Text(
                  'Breaking News',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        // color: AppColors.accent,
                        color: colors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                actions: [
                  if (state.showPagination)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Page ${state.pagination.currentPage} of ${state.pagination.totalPages}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              // color: AppColors.primary,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: GlassCategoryRow(
                  selected: state.selectedCategory,
                  onSelected: (cat) =>
                      context.read<CategoryCubit>().selectCategory(cat),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              _buildFeed(context, state),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: state.showPagination
                      ? PaginationBarWidget(
                          key: const ValueKey('headlines_pagination'),
                          meta: state.pagination,
                          isLoading:
                              state.status == HeadlinesPageLoadStatus.loading,
                          onPageTap: (page) =>
                              context.read<HeadlinesCubit>().goToPage(page),
                          onPrevious: () =>
                              context.read<HeadlinesCubit>().goToPreviousPage(),
                          onNext: () =>
                              context.read<HeadlinesCubit>().goToNextPage(),
                        )
                      : const SizedBox.shrink(key: ValueKey('no_bar')),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeed(BuildContext context, HeadlinesState state) {
    if (state.status == HeadlinesPageLoadStatus.loading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const ArticleCardSkeleton(),
            childCount: AppConstants.headlinesPageSize,
          ),
        ),
      );
    }

    if (state.status == HeadlinesPageLoadStatus.failure) {
      return SliverToBoxAdapter(
        child: ErrorState(
          message: state.error ?? 'Failed to load headlines',
          onRetry: () => context.read<HeadlinesCubit>().retry(),
        ),
      );
    }

    if (state.pageArticles.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.newspaper_rounded,
          title: 'No headlines found',
          subtitle: 'Try another category',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, index) {
            final article = state.pageArticles[index];
            return ArticleCard(
              article: article,
              onTap: () => Navigator.of(ctx).pushNamed(
                AppRoutes.artcileDetailsRoute,
                arguments: article,
              ),
            );
          },
          childCount: state.pageArticles.length,
        ),
      ),
    );
  }
}
