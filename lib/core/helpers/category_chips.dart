import 'package:flutter/material.dart';
import 'package:news_app/core/constants/app_constants.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final NewsCategory selected;
  final void Function(NewsCategory) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: NewsCategory.values.map((cat) {
          final isSelected = cat == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: FilterChip(
                label: Text(cat.label),
                selected: isSelected,
                onSelected: (_) => onSelected(cat),
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? colors.onPrimary : colors.onSurface,
                ),
                backgroundColor: colors.surfaceContainerHighest,
                selectedColor: colors.primary,
                checkmarkColor: colors.onPrimary,
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
                pressElevation: 0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
