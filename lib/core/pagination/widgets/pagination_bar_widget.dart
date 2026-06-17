import 'package:flutter/material.dart';
import 'package:news_app/core/pagination/helpers/nav_button.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../../theme/app_colors.dart';
import '../model/pagination_meta.dart';
import 'page_number_widget.dart';

class PaginationBarWidget extends StatelessWidget {
  final PaginationMeta meta;
  final void Function(int page) onPageTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isLoading;

  const PaginationBarWidget(
      {super.key,
      required this.meta,
      required this.onPageTap,
      required this.onPrevious,
      required this.onNext,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (meta.totalPages <= 1) return const SizedBox.shrink();
    final l10n = context.l10n;

    return AnimatedOpacity(
      opacity: isLoading ? 0.5 : 1,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink900.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NavButton(
              icon: Icons.chevron_left_rounded,
              onTap: meta.hasPreviousPage && !isLoading ? onPrevious : null,
              label: l10n.back,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: meta.pageWindow.map((page) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: PageNumber(
                          page: page,
                          isActive: page == meta.currentPage,
                          isLoading: isLoading && page == meta.currentPage,
                          onTap: isLoading ? null : () => onPageTap(page),
                        ),
                      );
                    }).toList(),
                  )),
            ),
            const SizedBox(
              width: 8,
            ),
            NavButton(
              icon: Icons.chevron_right_rounded,
              onTap: meta.hasNextPage && !isLoading ? onNext : null,
              label: l10n.forward,
              iconAfter: true,
            ),
          ],
        ),
      ),
    );
  }
}
