import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InAppBrowserView extends StatefulWidget {
  const InAppBrowserView({
    super.key,
    required this.url,
    required this.title,
    this.heroTag,
  });

  final String url;
  final String title;
  final String? heroTag;

  @override
  State<InAppBrowserView> createState() => _InAppBrowserViewState();
}

class _InAppBrowserViewState extends State<InAppBrowserView> {
  late final WebViewController _controller;

  int _loadingProgress = 0;
  bool _isLoading = true;
  bool _hasError = false;
  bool _canGoBack = false;
  bool _canGoForward = false;
  String _currentTitle = '';

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title;
    _buildController();
  }

  void _buildController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress;
              _isLoading = progress < 100;
            });
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
            _refreshNavState();
          },
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            _refreshNavState();
            // Pull the real page title from the DOM
            _controller
                .runJavaScriptReturningResult('document.title')
                .then((result) {
              if (!mounted) return;
              final raw = result.toString().replaceAll('"', '').trim();
              if (raw.isNotEmpty) setState(() => _currentTitle = raw);
            });
          },
          onWebResourceError: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
          onNavigationRequest: (request) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _refreshNavState() async {
    final back = await _controller.canGoBack();
    final fwd = await _controller.canGoForward();
    if (!mounted) return;
    setState(() {
      _canGoBack = back;
      _canGoForward = fwd;
    });
  }

  Future<void> _copyLink() async {
    final url = await _controller.currentUrl() ?? widget.url;
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Link copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: _buildAppBar(isDark, colors),
      body: Stack(
        children: [
          // ── WebView ───────────────────────────────────────────────────────
          if (!_hasError)
            WebViewWidget(controller: _controller)
          else
            _ErrorPage(
                url: widget.url,
                onRetry: () {
                  setState(() => _hasError = false);
                  _controller.loadRequest(Uri.parse(widget.url));
                }),

          // ── Progress bar (slides away when done) ──────────────────────────
          AnimatedOpacity(
            opacity: _isLoading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: LinearProgressIndicator(
              value: _loadingProgress / 100,
              backgroundColor: Colors.transparent,
              color: AppColors.primary,
              minHeight: 3,
            ),
          ),
        ],
      ),
      // ── Glass bottom navigation bar ───────────────────────────────────────
      bottomNavigationBar: _buildBottomBar(isDark, colors),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, ColorScheme colors) {
    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        tooltip: 'Close',
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentTitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          FutureBuilder<String?>(
            future: _controller.currentUrl(),
            builder: (_, snap) {
              final host = snap.hasData
                  ? Uri.tryParse(snap.data!)?.host ?? ''
                  : Uri.tryParse(widget.url)?.host ?? '';
              return Text(
                host,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurface.withValues(alpha: 0.5),
                  fontFamily: 'Poppins',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ],
      ),
      actions: [
        // Loading spinner / done indicator
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 20),
          tooltip: 'Copy link',
          onPressed: _copyLink,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBottomBar(bool isDark, ColorScheme colors) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 60 + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white)
                .withValues(alpha: isDark ? 0.6 : 0.85),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
          ),
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavIcon(
                icon: Icons.arrow_back_ios_new_rounded,
                enabled: _canGoBack,
                tooltip: 'Back',
                onTap: () async {
                  if (await _controller.canGoBack()) _controller.goBack();
                },
              ),
              _NavIcon(
                icon: Icons.arrow_forward_ios_rounded,
                enabled: _canGoForward,
                tooltip: 'Forward',
                onTap: () async {
                  if (await _controller.canGoForward()) _controller.goForward();
                },
              ),
              _NavIcon(
                icon: Icons.refresh_rounded,
                enabled: true,
                tooltip: 'Refresh',
                onTap: () => _controller.reload(),
              ),
              _NavIcon(
                icon: Icons.home_rounded,
                enabled: true,
                tooltip: 'Back to article',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom nav icon ──────────────────────────────────────────────────────────

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        onPressed: enabled ? onTap : null,
        color: enabled
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
        iconSize: 22,
      ),
    );
  }
}

// ─── Error page ───────────────────────────────────────────────────────────────

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.url, required this.onRetry});
  final String url;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Page failed to load',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              Uri.tryParse(url)?.host ?? url,
              style: tt.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
