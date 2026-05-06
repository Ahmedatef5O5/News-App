import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        surface: isLight ? AppColors.surface : AppColors.surfaceDark,
        onSurface: isLight ? AppColors.ink900 : Colors.white,
      ),
      scaffoldBackgroundColor:
          isLight ? AppColors.surfaceWarm : AppColors.surfaceDark,
      primaryColor: AppColors.primary,

      /// AppBar
      appBarTheme: AppBarTheme(
        backgroundColor:
            isLight ? AppColors.surfaceWarm : AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        systemOverlayStyle:
            isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isLight ? AppColors.ink900 : Colors.white,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(
          color: isLight ? AppColors.ink900 : Colors.white,
        ),
      ),

      // ── Text Theme ──────────────────────────────────────────────────────
      textTheme: TextTheme(
        // Headlines
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: isLight ? AppColors.ink900 : Colors.white,
          letterSpacing: -1.0,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: isLight ? AppColors.ink900 : Colors.white,
          letterSpacing: -0.5,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isLight ? AppColors.ink900 : Colors.white,
          letterSpacing: -0.3,
          height: 1.3,
        ),

        // Title
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: isLight ? AppColors.ink900 : Colors.white,
          letterSpacing: -0.2,
          height: 1.35,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color:
              isLight ? AppColors.ink700 : Colors.white.withValues(alpha: 0.9),
          letterSpacing: -0.1,
          height: 1.4,
        ),
        // Body
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color:
              isLight ? AppColors.ink700 : Colors.white.withValues(alpha: 0.85),
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color:
              isLight ? AppColors.ink500 : Colors.white.withValues(alpha: 0.7),
          height: 1.55,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color:
              isLight ? AppColors.ink300 : Colors.white.withValues(alpha: 0.5),
          height: 1.4,
        ),
        // Label
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color:
              isLight ? AppColors.ink700 : Colors.white.withValues(alpha: 0.8),
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color:
              isLight ? AppColors.ink300 : Colors.white.withValues(alpha: 0.5),
          letterSpacing: 0.3,
        ),
      ),

      // ── Input Decoration ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? AppColors.surfaceCard
            : Colors.white.withValues(alpha: 0.06),
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          color: AppColors.ink300,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: isLight ? AppColors.surface : const Color(0xFF1A1F35),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isLight
            ? AppColors.surfaceCard
            : Colors.white.withValues(alpha: 0.08),
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        side: BorderSide.none,
      ),

      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
