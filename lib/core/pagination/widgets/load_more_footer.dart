import 'package:flutter/material.dart';
import 'package:news_app/core/widgets/custom_loading_indicator.dart';
import '../../theme/app_colors.dart';

enum LoadMoreStatus { idle, loading, error, endOfList }

class LoadMoreFooter extends StatelessWidget {
  final LoadMoreStatus status;
  final VoidCallback? onRetry;
  final bool isLastPage;

  const LoadMoreFooter(
      {super.key, required this.status, this.onRetry, this.isLastPage = false});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return switch (status) {
      LoadMoreStatus.loading => const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CustomLoadingIndicator(
                radius: 12,
              ),
            ),
          ),
        ),
      LoadMoreStatus.error => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 18,
                color: AppColors.ink300,
              ),
              const SizedBox(width: 8),
              Text(
                'Failed to load',
                style: tt.bodySmall?.copyWith(color: AppColors.ink300),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onRetry,
                child: Text(
                  'Retry',
                  style: tt.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      LoadMoreStatus.endOfList => Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 1,
                color: AppColors.divider,
              ),
              const SizedBox(width: 12),
              Text(
                "You're all caught up",
                style: tt.bodySmall?.copyWith(
                  color: AppColors.ink300,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 1,
                color: AppColors.divider,
              ),
            ],
          ),
        ),
      LoadMoreStatus.idle => const SizedBox.shrink(),
    };
  }
}
