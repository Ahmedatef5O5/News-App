import 'package:flutter/material.dart';

class DotGridPainter extends CustomPainter {
  const DotGridPainter({required this.opacity});
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.045)
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
