import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_colors.dart';

/// Slim animated progress bar at the bottom of the splash.
/// Fills from left to right as the splash plays — gives users
/// a subconscious sense that "something is loading" without
/// showing an ugly spinner.
class SplashProgressBar extends StatelessWidget {
  const SplashProgressBar({
    super.key,
    required this.progress, // 0.0 → 1.0
    required this.opacity,
  });

  final double progress;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Version label
          Text(
            'v1.0.0',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.22),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Progress track
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(
              width: 120,
              height: 2,
              color: Colors.white.withValues(alpha: 0.10),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.accent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
