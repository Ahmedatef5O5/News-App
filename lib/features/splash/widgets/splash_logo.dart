import 'package:flutter/material.dart';
import 'package:news_app/features/splash/widgets/news_wave_icon.dart';
import 'package:news_app/features/splash/widgets/tag_line.dart';
import 'package:news_app/features/splash/widgets/wordmark_with_sweep.dart';

class SplashLogo extends StatelessWidget {
  final double iconScale;
  final double iconOpacity;
  final double wordmarkOffset;
  final double wordmarkOpacity;
  final double taglineOpacity;
  final double taglineOffset;
  final double sweepProgress;

  const SplashLogo({
    super.key,
    required this.iconScale,
    required this.iconOpacity,
    required this.wordmarkOffset,
    required this.wordmarkOpacity,
    required this.taglineOpacity,
    required this.taglineOffset,
    required this.sweepProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: iconScale,
          child: Opacity(
            opacity: iconOpacity.clamp(0.0, 1.0),
            child: const NewsWaveIcon(),
          ),
        ),
        const SizedBox(height: 28),
        Transform.translate(
          offset: Offset(0, wordmarkOffset),
          child: Opacity(
            opacity: wordmarkOpacity.clamp(0.0, 1.0),
            child: WordmarkWithSweep(sweepProgress: sweepProgress),
          ),
        ),
        const SizedBox(height: 12),
        Transform.translate(
          offset: Offset(0, taglineOffset),
          child: Opacity(
            opacity: taglineOpacity.clamp(0.0, 1.0),
            child: const Tagline(),
          ),
        ),
      ],
    );
  }
}
