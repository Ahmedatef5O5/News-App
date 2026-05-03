import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:news_app/features/Headlines/widgets/category_cat_meta.dart';
import '../../../core/theme/app_colors.dart';

class GlassCategoryCard extends StatelessWidget {
  const GlassCategoryCard({
    super.key,
    required this.meta,
    required this.isActive,
    required this.onTap,
  });

  final CatMeta meta;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    meta.color,
                    meta.color.withValues(alpha: 0.75),
                  ],
                )
              : null,
          color: isActive ? null : Colors.white,
          border: Border.all(
            color: isActive
                ? meta.color.withValues(alpha: 0.0)
                : AppColors.divider,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: meta.color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.ink900.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: isActive
                ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                : ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.25)
                        : meta.color.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    meta.icon,
                    size: 20,
                    color: isActive ? Colors.white : meta.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  meta.category.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.ink700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
