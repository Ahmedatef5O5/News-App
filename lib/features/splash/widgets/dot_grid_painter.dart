import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DotGridPainter extends CustomPainter {
  final double opacity;
  final bool isDark;

  const DotGridPainter({required this.opacity, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : AppColors.ink900)
          .withValues(alpha: opacity * (isDark ? 0.045 : 0.03))
      ..strokeCap = StrokeCap.round;

    const spacing = 28.0;
    const radius = 1.1;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DotGridPainter old) => old.opacity != opacity;
}
