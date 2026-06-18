import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashController {
  SplashController({required TickerProvider vsync}) : _vsync = vsync {
    _initController();
    _initAnimations();
  }

  final TickerProvider _vsync;

  late final AnimationController _controller;

  late final AnimationController backgroundCtrl = _controller;
  late final AnimationController tickerCtrl = _controller;
  late final AnimationController iconCtrl = _controller;
  late final AnimationController wordmarkCtrl = _controller;
  late final AnimationController taglineCtrl = _controller;
  late final AnimationController sweepCtrl = _controller;
  late final AnimationController exitCtrl = _controller;

  late final Animation<double> backgroundAnim;

  late final Animation<double> tickerSlide;
  late final Animation<double> tickerFade;

  late final Animation<double> iconScale;
  late final Animation<double> iconFade;

  late final Animation<double> wordmarkSlide;
  late final Animation<double> wordmarkFade;

  late final Animation<double> taglineFade;
  late final Animation<double> taglineSlide;

  late final Animation<double> sweepAnim;

  late final Animation<double> exitFade;
  late final Animation<double> exitScale;

  void _initController() {
    _controller = AnimationController(
      vsync: _vsync,
      duration: const Duration(milliseconds: 3600),
    );
  }

  void _initAnimations() {
    backgroundAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.22, curve: Curves.easeInOut),
    );

    tickerSlide = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.22, 0.38, curve: Curves.easeOutCubic),
    ));

    tickerFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.22, 0.38, curve: Curves.easeOut),
    );

    iconScale = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.38, 0.53, curve: Curves.elasticOut),
    ));

    iconFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.38, 0.50, curve: Curves.easeOut),
    );

    wordmarkSlide = Tween<double>(
      begin: 28.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.53, 0.70, curve: Curves.easeOutQuart),
    ));

    wordmarkFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.53, 0.70, curve: Curves.easeOut),
    );

    taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.70, 0.82, curve: Curves.easeOut),
    );

    taglineSlide = Tween<double>(
      begin: 12.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.70, 0.82, curve: Curves.easeOutCubic),
    ));

    sweepAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.82, 0.92, curve: Curves.easeInOut),
    );

    exitFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.92, 1.00, curve: Curves.easeInOutQuart),
    ));

    exitScale = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.92, 1.00, curve: Curves.easeOutExpo),
    ));
  }

  Future<void> play({required VoidCallback onComplete}) async {
    HapticFeedback.lightImpact();

    _controller.forward(from: 0.0);

    await Future.delayed(const Duration(milliseconds: 180));
    await Future.delayed(const Duration(milliseconds: 300));
    HapticFeedback.selectionClick();
    await Future.delayed(const Duration(milliseconds: 380));
    await Future.delayed(const Duration(milliseconds: 380));
    await Future.delayed(const Duration(milliseconds: 450));
    await Future.delayed(const Duration(milliseconds: 650));
    await Future.delayed(const Duration(milliseconds: 280));
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 580));

    onComplete();
  }

  void dispose() {
    _controller.dispose();
  }
}
