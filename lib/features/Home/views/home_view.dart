import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/di/service_locator.dart';
import 'package:news_app/core/cubits/category_cubit.dart';
import 'package:news_app/core/network/connectivity_cubit.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/theme/model/theme_model.dart';
import 'package:news_app/core/widgets/offline_banner.dart';
import 'package:news_app/features/home/cubit/home_cubit.dart';
import 'package:news_app/features/home/widgets/home_app_bar_widget.dart';
import 'package:news_app/features/home/widgets/home_carousel_section.dart';
import 'package:news_app/features/home/widgets/recommended_feed.dart';
import 'package:news_app/features/home/widgets/section_header_widget.dart';
import 'package:news_app/core/pagination/widgets/pagination_bar_widget.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../../../core/helpers/category_chips.dart';
import '../../../core/pagination/widgets/load_more_footer.dart';
import '../../../core/theme/theme_picker_dialog.dart';
import '../../../core/widgets/drawer/app_drawer.dart';
import '../widgets/page_info_badge.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..init(),
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
    final l10n = context.l10n;
    return Scaffold(
      drawer: const AppDrawer(),
      body: BlocConsumer<HomeCubit, HomeState>(
        // ── Rebuild only when fields that affect UI change ────────────────
        buildWhen: (prev, curr) =>
            prev.headlinesStatus != curr.headlinesStatus ||
            prev.pageStatus != curr.pageStatus ||
            prev.selectedCategory != curr.selectedCategory ||
            prev.isRefreshing != curr.isRefreshing ||
            prev.pagination != curr.pagination ||
            prev.fromCache != curr.fromCache ||
            prev.recommendedArticles.length != curr.recommendedArticles.length,
        // ── Scroll back to "For You" when page changes ────────────────────
        listenWhen: (prev, curr) =>
            prev.pagination.currentPage != curr.pagination.currentPage &&
            curr.pageStatus == PageLoadStatus.success,
        listener: (_, state) {
          if (state.pageStatus == PageLoadStatus.success &&
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
                // ── App bar ───────────────────────────────────────────────
                const HomeAppBarWidget(),

                // ── Offline banner ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: BlocBuilder<ConnectivityCubit, bool>(
                    builder: (_, isConnected) {
                      return OfflineBanner(
                          visible: !isConnected || state.fromCache);
                    },
                  ),
                ),

                // ── Category filter chips ─────────────────────────────────
                SliverToBoxAdapter(
                  child: CategoryChips(
                    selected: state.selectedCategory,
                    onSelected: (cat) =>
                        context.read<CategoryCubit>().selectCategory(cat),
                  ),
                ),

                // ── Breaking News header ──────────────────────────────────
                SliverToBoxAdapter(
                  child: SectionHeaderWidget(
                    label: l10n.breakingNews,
                    accentColor: AppColors.accent,
                    onViewAll: () => Navigator.of(context)
                        .pushNamed(AppRoutes.headlinesRoute),
                  ),
                ),

                // ── Carousel ──────────────────────────────────────────────
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

                // ── For You header ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: SectionHeaderWidget(
                    key: _forYouKey,
                    label: l10n.forYou,
                    accentColor: AppColors.primary,
                    trailing: state.showPaginationBar
                        ? PageInfoBadge(pagination: state.pagination)
                        : null,
                    onViewAll: () {},
                  ),
                ),

                // ── Recommended feed ──────────────────────────────────────
                RecommendedFeed(state: state),

                // ── Load-more footer ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: _buildLoadMoreFooter(context, state),
                ),

                // ── Pagination bar ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: state.showPaginationBar
                        ? PaginationBarWidget(
                            key: const ValueKey('pagination_bar'),
                            meta: state.pagination,
                            isLoading:
                                state.pageStatus == PageLoadStatus.loadingPage,
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
    return switch (state.pageStatus) {
      PageLoadStatus.failure => LoadMoreFooter(
          status: LoadMoreStatus.error,
          onRetry: () => context.read<HomeCubit>().goToPage(state.currentPage),
        ),
      PageLoadStatus.success
          when pag.isLastPage && state.recommendedArticles.isNotEmpty =>
        const LoadMoreFooter(
          status: LoadMoreStatus.endOfList,
          isLastPage: true,
        ),
      _ => const LoadMoreFooter(status: LoadMoreStatus.idle),
    };
  }
}
