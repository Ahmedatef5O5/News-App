import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/network/connectivity_cubit.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/l10n/app_localizations_x.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, this.message});
  final String? message;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _sizeFactor;
  late final Animation<double> _opacity;

  bool _showBackOnline = false;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _sizeFactor = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _opacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.75, curve: Curves.easeIn),
      reverseCurve: Curves.easeOut,
    );

    final isConnected = context.read<ConnectivityCubit>().state;
    if (!isConnected) {
      _ctrl.value = 1.0;
      _wasOffline = true;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onConnectivityChanged(bool isConnected) {
    if (!isConnected) {
      _wasOffline = true;
      if (mounted) setState(() => _showBackOnline = false);
      _ctrl.forward();
    } else {
      _ctrl.reverse();

      if (_wasOffline) {
        _wasOffline = false;
        if (mounted) {
          setState(() => _showBackOnline = true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _showBackOnline = false);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, bool>(
      listenWhen: (prev, curr) => prev != curr,
      listener: (_, isConnected) => _onConnectivityChanged(isConnected),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizeTransition(
            sizeFactor: _sizeFactor,
            axisAlignment: -1,
            child: FadeTransition(
              opacity: _opacity,
              child: _BannerRow(
                icon: Icons.wifi_off_rounded,
                message: widget.message ?? context.l10n.offlineShowingCached,
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                borderColor: AppColors.primary.withValues(alpha: 0.15),
                iconColor: AppColors.primary.withValues(alpha: 0.8),
                textColor: AppColors.primary.withValues(alpha: 0.9),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: _showBackOnline
                ? AnimatedOpacity(
                    opacity: _showBackOnline ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 220),
                    child: _BannerRow(
                      icon: Icons.wifi_rounded,
                      message: context.l10n.backOnline,
                      backgroundColor: const Color(0xFF2E7D32),
                      borderColor: const Color(0xFF1B5E20),
                      iconColor: Colors.white,
                      textColor: Colors.white,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _BannerRow extends StatelessWidget {
  const _BannerRow({
    required this.icon,
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });

  final IconData icon;
  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
