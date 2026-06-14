import 'package:flutter/material.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../../../core/pagination/model/pagination_meta.dart';
import '../../../core/theme/app_colors.dart';

class PageInfoBadge extends StatelessWidget {
  const PageInfoBadge({super.key, required this.pagination});
  final PaginationMeta pagination;

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l10n.pageOf(
          pagination.currentPage,
          pagination.totalPages,
        ),
        style: txtTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
