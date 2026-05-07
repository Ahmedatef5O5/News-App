import 'package:flutter/material.dart';
import 'package:news_app/core/models/article_model.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/features/home/widgets/headline_carousel_card.dart';
import '../../../core/helpers/empty_state.dart';
import '../../../core/helpers/error_state.dart';
import '../../../core/helpers/shimmer_box.dart';
import '../cubit/home_cubit.dart';

class HomeCarouselSection extends StatefulWidget {
  const HomeCarouselSection({
    super.key,
    required this.status,
    required this.articles,
    this.error,
    required this.onRetry,
    required this.onTap,
  });

  final LoadStatus status;
  final List<Article> articles;
  final String? error;
  final VoidCallback onRetry;
  final void Function(Article) onTap;

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

  @override
  Widget build(BuildContext context) {
    if (widget.status == LoadStatus.loading) {
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
        height: 200,
        child: ErrorState(
          message: widget.error ?? 'Failed to load headlines',
          onRetry: widget.onRetry,
        ),
      );
    }

    if (widget.articles.isEmpty) {
      return const SizedBox(
        height: 200,
        child: EmptyState(
          icon: Icons.newspaper_rounded,
          title: 'No headlines',
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
            itemBuilder: (_, index) => HeadlineCarouselCard(
              article: widget.articles[index],
              onTap: () => widget.onTap(widget.articles[index]),
            ),
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
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isActive ? AppColors.primary : AppColors.ink100,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
