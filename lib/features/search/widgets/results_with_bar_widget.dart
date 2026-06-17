import 'package:flutter/material.dart';
import 'package:news_app/core/models/article_detail_args.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../../../core/pagination/widgets/pagination_bar_widget.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/article_card_widget.dart';
import '../cubit/search_cubit.dart';

class ResultsWithBar extends StatelessWidget {
  final SearchState state;
  final ScrollController scrollController;
  final void Function(int) onPageTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const ResultsWithBar({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onPageTap,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final pag = state.pagination;
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Text(
                l10n.resultsCount(pag.totalResults),
                // '${pag.totalResults} results',
                style: txtTheme.bodySmall?.copyWith(
                  color: AppColors.ink300,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (pag.totalPages > 1)
                Text(
                  l10n.pageOf(pag.currentPage, pag.totalPages),
                  style: txtTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),

        // Article list
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.results.length,
            itemBuilder: (ctx, index) {
              final article = state.results[index];
              const heroContext = 'search';
              final heroTag = 'article-image-${article.uniqueId}-$heroContext';
              return ArticleCard(
                article: article,
                heroContext: heroContext,
                onTap: () => Navigator.of(ctx).pushNamed(
                  AppRoutes.artcileDetailsRoute,
                  arguments: ArticleDetailArgs(
                    article: article,
                    heroTag: heroTag,
                  ),
                ),
              );
            },
          ),
        ),

        // Pagination bar
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state.showPaginationBar
              ? PaginationBarWidget(
                  meta: pag,
                  isLoading: state.status == SearchStatus.loadingPage,
                  onPageTap: onPageTap,
                  onPrevious: onPrev,
                  onNext: onNext,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
