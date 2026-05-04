import 'package:flutter/material.dart';
import '../../../core/pagination/model/pagination_meta.dart';
import '../../../core/theme/app_colors.dart';

class PageInfoBadge extends StatelessWidget {
  const PageInfoBadge({super.key, required this.pagination});
  final PaginationMeta pagination;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Page ${pagination.currentPage} of ${pagination.totalPages}',
        style: tt.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
