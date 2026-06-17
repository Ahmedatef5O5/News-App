import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;

  const InitialsAvatar({super.key, required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.22,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
