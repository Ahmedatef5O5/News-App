import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({
    super.key,
    required this.progress,
    required this.child,
    required this.isDark,
  });

  final double progress;
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lightColors = [
      Color.lerp(const Color(0xFFF8F9FC), const Color(0xFFE8F0FE), progress)!,
      Color.lerp(const Color(0xFFFFFFFF), const Color(0xFFDCEAFD), progress)!,
      Color.lerp(const Color(0xFFF8F9FC), const Color(0xFFE8F0FE), progress)!,
    ];

    final darkColors = [
      Color.lerp(const Color(0xFF000000), const Color(0xFF040B1F), progress)!,
      Color.lerp(const Color(0xFF050505), const Color(0xFF0A1535), progress)!,
      Color.lerp(const Color(0xFF000000), const Color(0xFF0D1B3E), progress)!,
    ];

    return AnimatedContainer(
      duration: Duration.zero,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? darkColors : lightColors,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
