import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomAppBarIcon extends StatelessWidget {
  const CustomAppBarIcon({super.key, required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
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
          icon,
          size: 22,
          color: isDarkMode ? Colors.white : AppColors.ink900,
        ),
      ),
    );
  }
}
