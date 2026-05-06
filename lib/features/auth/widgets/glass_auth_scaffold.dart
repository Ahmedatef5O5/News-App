import 'dart:ui';
import 'package:flutter/material.dart';

class GlassAuthScaffold extends StatelessWidget {
  const GlassAuthScaffold({
    super.key,
    required this.child,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _AnimatedBackground(),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: const SizedBox.expand(),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Alignment> _begin;
  late final Animation<Alignment> _end;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _begin = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween:
            AlignmentTween(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween:
            AlignmentTween(begin: Alignment.topRight, end: Alignment.topLeft),
        weight: 1,
      ),
    ]).animate(_ctrl);

    _end = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
            begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
            begin: Alignment.bottomLeft, end: Alignment.bottomRight),
        weight: 1,
      ),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: _begin.value,
            end: _end.value,
            colors: isDark
                ? const [
                    Color(0xFF0A0E1A),
                    Color(0xFF0D1B3E),
                    Color(0xFF0F1221),
                  ]
                : const [
                    Color(0xFFE8F0FE),
                    Color(0xFFF8F9FC),
                    Color(0xFFDCEAFD),
                  ],
          ),
        ),
      ),
    );
  }
}
