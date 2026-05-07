import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/pagination/widgets/pagination_bar_widget.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/widgets/drawer/app_drawer.dart';
import 'package:news_app/features/home/widgets/home_carousel_section.dart';
import '../../../core/cubits/category_cubit.dart';
import '../../../core/helpers/category_chips.dart';
import '../../../core/pagination/widgets/load_more_footer.dart';
import '../../../core/theme/model/theme_model.dart';
import '../../../core/theme/theme_picker_dialog.dart';
import '../cubit/home_cubit.dart';
import '../widgets/home_app_bar_widget.dart';
import '../widgets/page_info_badge.dart';
import '../widgets/recommended_feed.dart';
import '../widgets/section_header_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(
        categoryCubit: context.read<CategoryCubit>(),
      )..init(),
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
  final GlobalKey _forYouKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.read<ThemeCubit>().hasChosen) {
        ThemePickerDialog.show(context);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToForYou() {
    if (_forYouKey.currentContext != null) {
      Scrollable.ensureVisible(
        _forYouKey.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        alignment: 0.0,
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
            _scrollToForYou();
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
                const HomeAppBarWidget(),

                SliverToBoxAdapter(
                  child: CategoryChips(
                    selected: state.selectedCategory,
                    onSelected: (cat) =>
                        context.read<CategoryCubit>().selectCategory(cat),
                  ),
                ),

                SliverToBoxAdapter(
                    child: SectionHeaderWidget(
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
                    child: SectionHeaderWidget(
                  key: _forYouKey,
                  label: 'For You',
                  accentColor: AppColors.primary,
                  trailing: state.showPaginationBar
                      ? PageInfoBadge(pagination: state.pagination)
                      : null,
                  onViewAll: () {},
                  // onViewAll: () => Navigator.of(context)
                  // .pushNamed(AppRoutes.headlinesRoute),
                )),

                RecommendedFeed(state: state),

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
                              _scrollToForYou();
                            },
                            onPrevious: () {
                              context.read<HomeCubit>().goToPreviousPage();
                              _scrollToForYou();
                            },
                            onNext: () {
                              context.read<HomeCubit>().goToNextPage();
                              _scrollToForYou();
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
