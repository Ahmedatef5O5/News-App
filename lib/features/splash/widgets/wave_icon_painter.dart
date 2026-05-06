import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WaveIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // White paint
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;

    final wavePath = Path();
    wavePath.moveTo(cx - 26, cy + 4);
    wavePath.cubicTo(
      cx - 18,
      cy - 12,
      cx - 10,
      cy - 12,
      cx,
      cy + 4,
    );
    wavePath.cubicTo(
      cx + 10,
      cy + 20,
      cx + 18,
      cy + 20,
      cx + 26,
      cy + 4,
    );
    canvas.drawPath(wavePath, paint);

    final barPaint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawLine(
      Offset(cx - 26, cy - 6),
      Offset(cx - 26, cy - 14),
      barPaint..color = Colors.white.withValues(alpha: 0.5),
    );

    canvas.drawLine(
      Offset(cx - 18, cy - 6),
      Offset(cx - 18, cy - 18),
      barPaint..color = Colors.white.withValues(alpha: 0.75),
    );

    canvas.drawLine(
      Offset(cx - 10, cy - 6),
      Offset(cx - 10, cy - 22),
      barPaint..color = Colors.white,
    );

    canvas.drawCircle(
      Offset(cx + 26, cy - 20),
      3.5,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx + 26, cy - 20),
      6.0,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.30)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(WaveIconPainter old) => false;
}
