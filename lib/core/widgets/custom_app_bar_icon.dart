import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomAppBarIcon extends StatelessWidget {
  const CustomAppBarIcon({super.key, required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceCard,
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }
}
