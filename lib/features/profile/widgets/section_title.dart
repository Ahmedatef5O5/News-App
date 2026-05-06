import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.4,
            color: AppColors.ink300,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
