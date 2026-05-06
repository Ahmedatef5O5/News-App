import 'package:flutter/material.dart';

class WordmarkWithSweep extends StatelessWidget {
  const WordmarkWithSweep({super.key, required this.sweepProgress});
  final double sweepProgress;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        final sweepX = bounds.left + bounds.width * (sweepProgress * 1.4 - 0.2);
        const sweepWidth = 120.0;

        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white,
            Colors.white,
            Colors.white.withValues(alpha: 0.92),
            const Color(0xFFE8F0FF),
            Colors.white.withValues(alpha: 0.92),
            Colors.white,
            Colors.white,
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
      child: const Text(
        'NewsWave',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 42,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -1.5,
          height: 1.0,
        ),
      ),
    );
  }
}
