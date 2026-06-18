import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/features/splash/controller/splash_controller.dart';
import 'package:news_app/features/splash/widgets/splash_background.dart';
import 'package:news_app/features/splash/widgets/splash_logo.dart';
import 'package:news_app/features/splash/widgets/splash_progress_bar.dart';
import 'package:news_app/features/splash/widgets/ticker_lines.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../widgets/dot_grid_painter.dart';
import '../widgets/glow_orb.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late final SplashController _ctrl;

  bool _isAnimationDone = false;
  String? _nextRoute;
  bool _authResolved = false;

  @override
  void initState() {
    super.initState();
    _ctrl = SplashController(vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.play(onComplete: () {
        _isAnimationDone = true;
        _checkAndNavigate();
      });
    });

    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted || _nextRoute != null || _authResolved) return;
      _nextRoute = AppRoutes.signInRoute;
      _checkAndNavigate();
    });
  }

  void _checkAndNavigate() {
    if (!mounted) return;

    if (_isAnimationDone && _nextRoute != null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      SystemChrome.setSystemUIOverlayStyle(
        isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      );
      Navigator.of(context).pushReplacementNamed(_nextRoute!);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark ? Colors.black : Colors.white,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));

    return BlocListener<AuthCubit, AuthUserState>(
      listener: (context, state) {
        _authResolved = true;

        _nextRoute = switch (state) {
          AuthAuthenticated() => state.needsOnboarding
              ? AppRoutes.onboardingRoute
              : AppRoutes.homeRoute,
          AuthGuest() => AppRoutes.homeRoute,
          AuthUnauthenticated() || AuthError() => AppRoutes.signInRoute,
          _ => null,
        };

        _checkAndNavigate();
      },
      child: AnimatedBuilder(
        animation: _ctrl.exitCtrl,
        builder: (context, _) {
          return Scaffold(
            body: SplashBackground(
              progress: _ctrl.backgroundAnim.value,
              isDark: isDark,
              child: Opacity(
                opacity: _ctrl.exitFade.value,
                child: Transform.scale(
                  scale: _ctrl.exitScale.value,
                  child: _SplashContent(
                    ctrl: _ctrl,
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ================= UI CONTENT =================

class _SplashContent extends StatelessWidget {
  const _SplashContent({
    required this.ctrl,
    required this.isDark,
  });

  final SplashController ctrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        _BackgroundOrbs(
          ctrl: ctrl,
          isDark: isDark,
          size: size,
        ),
        _DotGrid(ctrl: ctrl, isDark: isDark),
        _Ticker(ctrl: ctrl),
        _Logo(ctrl: ctrl),
        _ProgressBar(ctrl: ctrl),
      ],
    );
  }
}

/// ================= SECTIONS =================

class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs({
    required this.ctrl,
    required this.isDark,
    required this.size,
  });

  final SplashController ctrl;
  final bool isDark;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ctrl.backgroundCtrl,
        ctrl.sweepCtrl,
      ]),
      builder: (_, __) {
        return Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                GlowOrb(
                  alignment: const Alignment(-0.6, -0.5),
                  color: const Color(0xFF1A73E8),
                  opacity: ctrl.backgroundAnim.value * (isDark ? 0.18 : 0.1),
                  size: size.width * 0.85,
                ),
                GlowOrb(
                  alignment: const Alignment(0.7, 0.6),
                  color: const Color(0xFF0D47A1),
                  opacity: ctrl.backgroundAnim.value * (isDark ? 0.12 : 0.08),
                  size: size.width * 0.7,
                ),
                GlowOrb(
                  alignment: const Alignment(0.3, -0.8),
                  color: const Color(0xFFFF6B35),
                  opacity: ctrl.sweepCtrl.value * 0.08,
                  size: size.width * 0.4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DotGrid extends StatelessWidget {
  const _DotGrid({
    required this.ctrl,
    required this.isDark,
  });

  final SplashController ctrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl.backgroundCtrl,
      builder: (_, __) {
        return Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: DotGridPainter(
                opacity: ctrl.backgroundAnim.value,
                isDark: isDark,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Ticker extends StatelessWidget {
  const _Ticker({required this.ctrl});

  final SplashController ctrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl.tickerCtrl,
      builder: (_, __) {
        return Positioned.fill(
          child: IgnorePointer(
            child: TickerLines(
              slideProgress: ctrl.tickerSlide.value,
              fadeProgress: ctrl.tickerFade.value,
            ),
          ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.ctrl});

  final SplashController ctrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ctrl.iconCtrl,
        ctrl.wordmarkCtrl,
        ctrl.taglineCtrl,
        ctrl.sweepCtrl,
      ]),
      builder: (_, __) {
        return Center(
          child: SplashLogo(
            iconScale: ctrl.iconScale.value,
            iconOpacity: ctrl.iconFade.value,
            wordmarkOffset: ctrl.wordmarkSlide.value,
            wordmarkOpacity: ctrl.wordmarkFade.value,
            taglineOpacity: ctrl.taglineFade.value,
            taglineOffset: ctrl.taglineSlide.value,
            sweepProgress: ctrl.sweepAnim.value,
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.ctrl});

  final SplashController ctrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ctrl.wordmarkCtrl,
        ctrl.taglineCtrl,
        ctrl.sweepCtrl,
      ]),
      builder: (_, __) {
        final barProgress = (ctrl.wordmarkCtrl.value * 0.5) +
            (ctrl.taglineCtrl.value * 0.3) +
            (ctrl.sweepCtrl.value * 0.2);

        return Positioned(
          bottom: MediaQuery.paddingOf(context).bottom + 40,
          left: 0,
          right: 0,
          child: Center(
            child: SplashProgressBar(
              progress: barProgress,
              opacity: ctrl.wordmarkFade.value,
            ),
          ),
        );
      },
    );
  }
}
