import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashController {
  SplashController({required TickerProvider vsync}) : _vsync = vsync;

  final TickerProvider _vsync;

  late final AnimationController backgroundCtrl = AnimationController(
    vsync: _vsync,
    duration: const Duration(milliseconds: 1000),
  );

  late final AnimationController tickerCtrl = AnimationController(
    vsync: _vsync,
    duration: const Duration(milliseconds: 700),
  );

  late final AnimationController iconCtrl = AnimationController(
    vsync: _vsync,
    duration: const Duration(milliseconds: 550),
  );

  late final AnimationController wordmarkCtrl = AnimationController(
    vsync: _vsync,
    duration: const Duration(milliseconds: 650),
  );

  late final AnimationController taglineCtrl = AnimationController(
    vsync: _vsync,
    duration: const Duration(milliseconds: 450),
  );

  late final AnimationController sweepCtrl = AnimationController(
    vsync: _vsync,
    duration: const Duration(milliseconds: 550),
  );

  late final AnimationController exitCtrl = AnimationController(
    vsync: _vsync,
    duration: const Duration(milliseconds: 600),
  );

  late final Animation<double> backgroundAnim = CurvedAnimation(
    parent: backgroundCtrl,
    curve: Curves.easeInOut,
  );

  late final Animation<double> tickerSlide = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).animate(CurvedAnimation(
    parent: tickerCtrl,
    curve: Curves.easeOutCubic,
  ));

  late final Animation<double> tickerFade = CurvedAnimation(
    parent: tickerCtrl,
    curve: Curves.easeOut,
  );

  late final Animation<double> iconScale = Tween<double>(
    begin: 0.3,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: iconCtrl,
    curve: Curves.elasticOut,
  ));

  late final Animation<double> iconFade = CurvedAnimation(
    parent: iconCtrl,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
  );

  late final Animation<double> wordmarkSlide = Tween<double>(
    begin: 28.0,
    end: 0.0,
  ).animate(CurvedAnimation(
    parent: wordmarkCtrl,
    curve: Curves.easeOutQuart,
  ));

  late final Animation<double> wordmarkFade = CurvedAnimation(
    parent: wordmarkCtrl,
    curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
  );

  late final Animation<double> taglineFade = CurvedAnimation(
    parent: taglineCtrl,
    curve: Curves.easeOut,
  );

  late final Animation<double> taglineSlide = Tween<double>(
    begin: 12.0,
    end: 0.0,
  ).animate(CurvedAnimation(
    parent: taglineCtrl,
    curve: Curves.easeOutCubic,
  ));

  late final Animation<double> sweepAnim = CurvedAnimation(
    parent: sweepCtrl,
    curve: Curves.easeInOut,
  );

  late final Animation<double> exitFade = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).animate(CurvedAnimation(
    parent: exitCtrl,
    curve: Curves.easeInOutQuart,
  ));

  late final Animation<double> exitScale = Tween<double>(
    begin: 1.0,
    end: 1.15,
  ).animate(CurvedAnimation(
    parent: exitCtrl,
    curve: Curves.easeOutExpo,
  ));

  Future<void> play({required VoidCallback onComplete}) async {
    HapticFeedback.lightImpact();

    backgroundCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 180));

    tickerCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    iconCtrl.forward();
    HapticFeedback.selectionClick();
    await Future.delayed(const Duration(milliseconds: 380));

    wordmarkCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 380));

    taglineCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 450));

    sweepCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 650));

    await Future.delayed(const Duration(milliseconds: 280));

    HapticFeedback.lightImpact();
    exitCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 580));

    onComplete();
  }

  void dispose() {
    backgroundCtrl.dispose();
    tickerCtrl.dispose();
    iconCtrl.dispose();
    wordmarkCtrl.dispose();
    taglineCtrl.dispose();
    sweepCtrl.dispose();
    exitCtrl.dispose();
  }
}
