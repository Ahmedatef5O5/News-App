import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_colors.dart';

/// Animated shimmer effect for loading states.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(_animation.value - 1, 0),
            end: Alignment(_animation.value + 1, 0),
            colors: const [
              AppColors.shimmer,
              AppColors.shimmerHighlight,
              AppColors.shimmer,
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for an ArticleCard row.
class ArticleCardSkeleton extends StatelessWidget {
  const ArticleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 110,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ShimmerBox(width: 110, height: 110, borderRadius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBox(width: 80, height: 10),
                const SizedBox(height: 8),
                ShimmerBox(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                ShimmerBox(width: 140, height: 14),
                const SizedBox(height: 8),
                ShimmerBox(width: 60, height: 10),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

/// Skeleton for a carousel card.
class CarouselCardSkeleton extends StatelessWidget {
  const CarouselCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ShimmerBox(
          width: double.infinity,
          height: 220,
          borderRadius: 24,
        ),
      ),
    );
  }
}
