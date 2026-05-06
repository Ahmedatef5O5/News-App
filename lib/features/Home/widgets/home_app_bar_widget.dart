import 'package:flutter/material.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar_icon.dart';

class HomeAppBarWidget extends StatelessWidget {
  const HomeAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
            margin: const EdgeInsets.only(left: 18, right: 8),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.surfaceCard,
              border: Border.all(
                color: isDarkMode
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Icon(
              Icons.menu_rounded,
              size: 22,
              color: isDarkMode ? Colors.white : AppColors.ink900,
            ),
          ),
        ),
      ),
      title: Text(
        'NewsWave',
        style: txtTheme.headlineMedium?.copyWith(
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
