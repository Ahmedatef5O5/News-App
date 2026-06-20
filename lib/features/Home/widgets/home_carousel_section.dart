import 'package:flutter/material.dart';
import 'package:news_app/core/exceptions/error_localization.dart';
import 'package:news_app/core/helpers/empty_state.dart';
import 'package:news_app/core/helpers/error_state.dart';
import 'package:news_app/core/helpers/shimmer_box.dart';
import 'package:news_app/core/models/article_model.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/features/home/cubit/home_cubit.dart';
import 'package:news_app/features/home/widgets/headline_carousel_card.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../../../core/models/article_detail_args.dart';

class HomeCarouselSection extends StatefulWidget {
  const HomeCarouselSection({
    super.key,
    required this.status,
    required this.articles,
    this.error,
    required this.onRetry,
    this.onTap,
  });

  final LoadStatus status;
  final List<Article> articles;
  final Object? error;
  final VoidCallback onRetry;
  final void Function(Article)? onTap;

  @override
  State<HomeCarouselSection> createState() => _HomeCarouselSectionState();
}

class _HomeCarouselSectionState extends State<HomeCarouselSection> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateTo(BuildContext context, Article article, String heroTag) {
    if (widget.onTap != null) {
      widget.onTap!(article);
      return;
    }
    Navigator.of(context).pushNamed(
      AppRoutes.artcileDetailsRoute,
      arguments: ArticleDetailArgs(article: article, heroTag: heroTag),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (widget.status == LoadStatus.loading ||
        widget.status == LoadStatus.initial) {
      return SizedBox(
        height: 230,
        child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: PageController(viewportFraction: 0.88),
          itemCount: 3,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: CarouselCardSkeleton(),
          ),
        ),
      );
    }

    if (widget.status == LoadStatus.failure) {
      return SizedBox(
        height: 278,
        child: ErrorState(
          message: resolveErrorMessage(
            widget.error,
            l10n,
            fallback: l10n.failedToLoad,
          ),
          onRetry: widget.onRetry,
        ),
      );
    }

    if (widget.articles.isEmpty) {
      return SizedBox(
        height: 200,
        child: EmptyState(
          icon: Icons.newspaper_rounded,
          title: l10n.noArticlesFound,
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.articles.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (ctx, index) {
              final article = widget.articles[index];
              final card = HeadlineCarouselCard(
                article: article,
                onTap: () => _navigateTo(
                    ctx,
                    article,
                    // Use the card's own heroTag getter
                    'article-image-${article.uniqueId}-carousel'),
              );
              return card;
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.articles.length.clamp(0, 8),
            (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.2),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
