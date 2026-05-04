import 'package:flutter/cupertino.dart';
import 'package:news_app/features/Headlines/widgets/category_cat_meta.dart';
import 'package:news_app/features/Headlines/widgets/glass_category_card.dart';
import '../../../core/constants/app_constants.dart';

class GlassCategoryRow extends StatelessWidget {
  const GlassCategoryRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final NewsCategory selected;
  final void Function(NewsCategory) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final meta = categories[i];
          final isActive = meta.category == selected;
          return GlassCategoryCard(
            meta: meta,
            isActive: isActive,
            onTap: () => onSelected(meta.category),
          );
        },
      ),
    );
  }
}
