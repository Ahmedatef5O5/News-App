import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String label;
  final bool iconAfter;

  const NavButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
    this.iconAfter = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final color = isDisabled ? AppColors.ink100 : AppColors.ink700;

    final iconWidget = Icon(icon, size: 18, color: color);
    final labelWidget = Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );

    final children = iconAfter
        ? [labelWidget, const SizedBox(width: 2), iconWidget]
        : [iconWidget, const SizedBox(width: 2), labelWidget];

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
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
