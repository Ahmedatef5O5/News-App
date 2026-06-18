import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_colors.dart';

enum SnackBarType { error, success, info }

class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.error,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    final color = switch (type) {
      SnackBarType.error => AppColors.error,
      SnackBarType.success => AppColors.primary,
      SnackBarType.info => Colors.blueGrey,
    };

    final icon = switch (type) {
      SnackBarType.error => Icons.error_outline_rounded,
      SnackBarType.success => Icons.check_circle_outline_rounded,
      SnackBarType.info => Icons.info_outline_rounded,
    };

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: duration,
        ),
      );
  }
}
