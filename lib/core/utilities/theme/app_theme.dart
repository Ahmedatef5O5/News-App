import 'package:flutter/material.dart';
import 'package:news_app/core/utilities/theme/app_colors.dart';

class AppTheme {
  static ThemeData get maintheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor!),
    useMaterial3: true,
    primaryColor: AppColors.primaryColor,
    appBarTheme: const AppBarTheme(),
  );
}
