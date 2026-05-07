import 'package:flutter/material.dart';
import 'package:news_app/features/splash/widgets/wave_icon_painter.dart';
import '../../../core/theme/app_colors.dart';

class NewsWaveIcon extends StatelessWidget {
  const NewsWaveIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A73E8),
            Color(0xFF0D47A1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.50),
            blurRadius: 36,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 60,
            spreadRadius: 0,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: CustomPaint(
        painter: WaveIconPainter(),
      ),
    );
  }
}
