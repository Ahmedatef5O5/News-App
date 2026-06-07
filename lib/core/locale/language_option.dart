import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';

class LanguageOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Locale locale;
  final Locale selected;
  final VoidCallback onTap;

  const LanguageOption({
    super.key,
    required this.icon,
    required this.label,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = locale.languageCode == selected.languageCode;
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
