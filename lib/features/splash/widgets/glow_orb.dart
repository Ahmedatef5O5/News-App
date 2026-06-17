import 'package:flutter/material.dart';

class GlowOrb extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double opacity;
  final double size;

  const GlowOrb({
    super.key,
    required this.alignment,
    required this.color,
    required this.opacity,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: opacity),
              blurRadius: size * 0.9,
              spreadRadius: size * 0.1,
            ),
          ],
        ),
      ),
    );
  }
}
