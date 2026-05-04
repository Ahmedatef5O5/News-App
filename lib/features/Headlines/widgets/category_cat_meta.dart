import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class CatMeta {
  final NewsCategory category;
  final IconData icon;
  final Color color;

  const CatMeta(this.category, this.icon, this.color);
}

const List<CatMeta> categories = [
  CatMeta(NewsCategory.general, Icons.public_rounded, AppColors.primary),
  CatMeta(
      NewsCategory.business, Icons.trending_up_rounded, AppColors.catBusiness),
  CatMeta(NewsCategory.technology, Icons.memory_rounded, AppColors.catTech),
  CatMeta(
      NewsCategory.sports, Icons.sports_soccer_rounded, AppColors.catSports),
  CatMeta(NewsCategory.health, Icons.favorite_rounded, AppColors.catHealth),
  CatMeta(NewsCategory.entertainment, Icons.movie_rounded,
      AppColors.catEntertainment),
  CatMeta(NewsCategory.science, Icons.science_rounded, AppColors.catScience),
];
