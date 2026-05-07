import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WordmarkWithSweep extends StatelessWidget {
  const WordmarkWithSweep({super.key, required this.sweepProgress});
  final double sweepProgress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : AppColors.ink900;
    final fadeColor =
        isDark ? Colors.white.withValues(alpha: 0.92) : AppColors.ink500;
    final sweepColor = isDark ? const Color(0xFFE8F0FF) : AppColors.primary;

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        final sweepX = bounds.left + bounds.width * (sweepProgress * 1.4 - 0.2);
        const sweepWidth = 120.0;

        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            baseColor,
            baseColor,
            fadeColor,
            sweepColor,
            fadeColor,
            baseColor,
            baseColor,
            // Colors.white,
            // Colors.white,
            // Colors.white.withValues(alpha: 0.92),
            // const Color(0xFFE8F0FF),
            // Colors.white.withValues(alpha: 0.92),
            // Colors.white,
            // Colors.white,
          ],
          stops: [
            0.0,
            ((sweepX - sweepWidth) / bounds.width).clamp(0.0, 1.0),
            ((sweepX - sweepWidth * 0.5) / bounds.width).clamp(0.0, 1.0),
            (sweepX / bounds.width).clamp(0.0, 1.0),
            ((sweepX + sweepWidth * 0.5) / bounds.width).clamp(0.0, 1.0),
            ((sweepX + sweepWidth) / bounds.width).clamp(0.0, 1.0),
            1.0,
          ],
        ).createShader(bounds);
      },
      child: Text(
        'NewsWave',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 42,
          fontWeight: FontWeight.w700,
          // color: Colors.white,
          color: baseColor,
          letterSpacing: -1.5,
          height: 1.0,
        ),
      ),
    );
  }
}
