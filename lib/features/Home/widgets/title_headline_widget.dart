import 'package:flutter/material.dart';
import 'package:news_app/core/utilities/theme/app_colors.dart';

class TitleHeadlineWidget extends StatelessWidget {
  const TitleHeadlineWidget({
    super.key,
    required this.title,
    this.onTap,
    this.txtBtn,
    this.wordSpacing,
  });
  final String title;
  final String? txtBtn;
  final double? wordSpacing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: AppColors.blackColor,
              wordSpacing: wordSpacing,
            ),
          ),
          Spacer(),
          TextButton(
            onPressed: onTap,
            child: Text(
              txtBtn ?? '',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: Theme.of(context).primaryColor,
                wordSpacing: wordSpacing,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
