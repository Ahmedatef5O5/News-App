import 'package:flutter/material.dart';
import 'package:news_app/core/widgets/custom_loading_indicator.dart';
import '../../theme/app_colors.dart';

class PageNumber extends StatelessWidget {
  final int page;
  final bool isActive;
  final bool isLoading;
  final VoidCallback? onTap;

  const PageNumber({
    super.key,
    required this.page,
    required this.isActive,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: isActive ? 42 : 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: isLoading && isActive
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CustomLoadingIndicator(
                    color: Colors.white,
                  ),
                )
              : AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.ink500,
                  ),
                  child: Text('$page'),
                ),
        ),
      ),
    );
  }
}
