import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/models/article_model.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/features/favorites/favorite_cubit/favorite_cubit.dart';
import '../../features/favorites/favorite_cubit/favorite_state.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.article,
    this.size = 36,
    this.isGlass = false,
    this.iconColor,
  });

  final Article article;
  final double size;
  final bool isGlass;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen: (prev, curr) {
        final wasIn = prev.isSaved(article);
        final isIn = curr.isSaved(article);
        return wasIn != isIn;
      },
      builder: (context, state) {
        final isSaved = state.isSaved(article);
        return GestureDetector(
          onTap: () {
            context.read<FavoritesCubit>().toggleFavorite(article);
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    isSaved ? 'Removed from saved' : 'Article saved',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(milliseconds: 1800),
                ),
              );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isGlass
                  ? Colors.white.withValues(alpha: 0.2)
                  : (isSaved
                      ? AppColors.saved.withValues(alpha: 0.12)
                      : Colors.transparent),
            ),
            child: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              size: size * 0.5,
              color:
                  isSaved ? AppColors.saved : (iconColor ?? AppColors.ink300),
            ),
          ),
        );
      },
    );
  }
}
