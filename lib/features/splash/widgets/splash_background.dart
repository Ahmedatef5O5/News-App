import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({
    super.key,
    required this.progress,
    required this.child,
  });

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration.zero,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(
              const Color(0xFF000000),
              const Color(0xFF040B1F),
              progress,
            )!,
            Color.lerp(
              const Color(0xFF050505),
              const Color(0xFF0A1535),
              progress,
            )!,
            Color.lerp(
              const Color(0xFF000000),
              const Color(0xFF0D1B3E),
              progress,
            )!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
