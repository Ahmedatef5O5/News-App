import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class TickerLines extends StatelessWidget {
  const TickerLines({
    super.key,
    required this.slideProgress,
    required this.fadeProgress,
  });

  final double slideProgress;
  final double fadeProgress;

  static const _lines = [
    _TickerData(fromRight: false, width: 0.72, topFraction: 0.118, delay: 0.00),
    _TickerData(fromRight: true, width: 0.55, topFraction: 0.148, delay: 0.05),
    _TickerData(fromRight: false, width: 0.40, topFraction: 0.178, delay: 0.10),
    _TickerData(fromRight: true, width: 0.65, topFraction: 0.795, delay: 0.00),
    _TickerData(fromRight: false, width: 0.50, topFraction: 0.825, delay: 0.05),
    _TickerData(fromRight: true, width: 0.38, topFraction: 0.855, delay: 0.10),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : AppColors.primary;
    final peakOpacity = isDark ? 0.9 : 0.25;

    return Stack(
      children: _lines.map((line) {
        final adjustedFade =
            ((fadeProgress - line.delay) / (1.0 - line.delay)).clamp(0.0, 1.0);
        final adjustedSlide =
            ((slideProgress + line.delay) / (1.0 + line.delay)).clamp(0.0, 1.0);

        final dx = line.fromRight
            ? size.width * adjustedSlide
            : -size.width * adjustedSlide;

        return Positioned(
          top: size.height * line.topFraction,
          left: line.fromRight ? null : 24,
          right: line.fromRight ? 24 : null,
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: Opacity(
              opacity: adjustedFade * (isDark ? 0.22 : 0.6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  width: size.width * line.width,
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        baseColor.withValues(alpha: 0),
                        baseColor.withValues(alpha: peakOpacity),
                        baseColor.withValues(alpha: 0),
                      ],
                      stops: line.fromRight
                          ? const [0.0, 0.6, 1.0]
                          : const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TickerData {
  const _TickerData({
    required this.fromRight,
    required this.width,
    required this.topFraction,
    required this.delay,
  });

  final bool fromRight;
  final double width; // Fraction of screen width
  final double topFraction; // Fraction of screen height
  final double delay; // Stagger: 0.0–0.15
}
