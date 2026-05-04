import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class NavButton extends StatelessWidget {
  const NavButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
    this.iconAfter = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String label;
  final bool iconAfter;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final color = isDisabled ? AppColors.ink100 : AppColors.ink700;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: iconAfter
          ? [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(width: 2),
              Icon(icon, size: 18, color: color),
            ]
          : [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.surfaceCard.withValues(alpha: 0.5)
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(10),
        ),
        child: content,
      ),
    );
  }
}
