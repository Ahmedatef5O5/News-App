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
        if (state is AuthAuthenticated) {
          _nextRoute = state.needsOnboarding
              ? AppRoutes.onboardingRoute
              : AppRoutes.homeRoute;
        } else if (state is AuthUnauthenticated || state is AuthError) {
          _nextRoute = AppRoutes.signInRoute;
        }
        _checkAndNavigate();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _ctrl.backgroundCtrl,
          _ctrl.tickerCtrl,
          _ctrl.iconCtrl,
          _ctrl.wordmarkCtrl,
          _ctrl.taglineCtrl,
          _ctrl.sweepCtrl,
          _ctrl.exitCtrl,
        ]),
        builder: (context, _) {
          final exitFade = _ctrl.exitFade.value;
          final exitScale = _ctrl.exitScale.value;
          final size = MediaQuery.sizeOf(context);

          final barProgress = (_ctrl.wordmarkCtrl.value * 0.5) +
              (_ctrl.taglineCtrl.value * 0.3) +
              (_ctrl.sweepCtrl.value * 0.2);

          return Scaffold(
            body: SplashBackground(
              progress: _ctrl.backgroundAnim.value,
              isDark: isDark,
              child: Opacity(
                opacity: exitFade,
                child: Transform.scale(
                  scale: exitScale,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Stack(
                            children: [
                              GlowOrb(
                                alignment: const Alignment(-0.6, -0.5),
                                color: const Color(0xFF1A73E8),
                                opacity: _ctrl.backgroundAnim.value *
                                    (isDark ? 0.18 : 0.1),
                                size: size.width * 0.85,
                              ),
                              GlowOrb(
                                alignment: const Alignment(0.7, 0.6),
                                color: const Color(0xFF0D47A1),
                                opacity: _ctrl.backgroundAnim.value *
                                    (isDark ? 0.12 : 0.08),
                                size: size.width * 0.70,
                              ),
                              GlowOrb(
                                alignment: const Alignment(0.3, -0.8),
                                color: const Color(0xFFFF6B35),
                                opacity: _ctrl.sweepCtrl.value * 0.08,
                                size: size.width * 0.40,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: DotGridPainter(
                              opacity: _ctrl.backgroundAnim.value,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: TickerLines(
                            slideProgress: _ctrl.tickerSlide.value,
                            fadeProgress: _ctrl.tickerFade.value,
                          ),
                        ),
                      ),
                      Center(
                        child: SplashLogo(
                          iconScale: _ctrl.iconScale.value,
                          iconOpacity: _ctrl.iconFade.value,
                          wordmarkOffset: _ctrl.wordmarkSlide.value,
                          wordmarkOpacity: _ctrl.wordmarkFade.value,
                          taglineOpacity: _ctrl.taglineFade.value,
                          taglineOffset: _ctrl.taglineSlide.value,
                          sweepProgress: _ctrl.sweepAnim.value,
                        ),
                      ),
                      Positioned(
                        bottom: MediaQuery.paddingOf(context).bottom + 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SplashProgressBar(
                            progress: barProgress,
                            opacity: _ctrl.wordmarkFade.value,
                          ),
                        ),
                      ),
                    ],
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
