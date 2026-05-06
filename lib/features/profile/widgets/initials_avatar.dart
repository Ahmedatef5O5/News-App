import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.initials, required this.size});
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: size * 0.32,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
