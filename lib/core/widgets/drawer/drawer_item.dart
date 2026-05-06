import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color =
        iconColor ?? (isActive ? AppColors.primary : AppColors.ink500);

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: tt.bodyMedium?.copyWith(
          color: labelColor ?? (isActive ? AppColors.primary : null),
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isActive ? AppColors.primary.withValues(alpha: 0.08) : null,
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
