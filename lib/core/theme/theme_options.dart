import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_colors.dart';

class ThemeOption extends StatelessWidget {
  const ThemeOption({
    super.key,
    required this.icon,
    required this.label,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final ThemeMode mode;
  final ThemeMode selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == selected;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.ink100,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.white : AppColors.ink500,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.ink700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
