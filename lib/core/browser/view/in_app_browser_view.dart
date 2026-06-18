import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app/core/browser/widgets/error_page_widget.dart';
import 'package:news_app/core/browser/widgets/nav_icon_widget.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
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
  String _currentUrl = '';
  String _currentHost = '';

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
            setState(() {
              _isLoading = false;
              _currentUrl = url;
              _currentHost = Uri.tryParse(url)?.host ?? '';
            });
            _refreshNavState();
            _controller
                .runJavaScriptReturningResult('document.title')
                .then((result) {
              if (!mounted) return;
              final raw = result.toString().replaceAll('"', '').trim();
              if (raw.isNotEmpty) setState(() => _currentTitle = raw);
            });
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != true) return;

            if (!mounted) return;

            if (_currentUrl.isEmpty) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);

            if (uri != null &&
                (uri.scheme == 'http' || uri.scheme == 'https')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
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
    final url = _currentUrl.isNotEmpty ? _currentUrl : widget.url;
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.linkCopied),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: appBarBrowser(isDark, colors),
      body: Stack(
        children: [
          if (!_hasError)
            WebViewWidget(controller: _controller)
          else
            ErrorPage(
                url: widget.url,
                onRetry: () {
                  setState(() => _hasError = false);
                  _controller.loadRequest(Uri.parse(widget.url));
                }),
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
      bottomNavigationBar: bottomBarBrowser(isDark, colors),
    );
  }

  PreferredSizeWidget appBarBrowser(bool isDark, ColorScheme colors) {
    final l10n = context.l10n;
    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        tooltip: l10n.close,
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
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            _currentHost,
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
      actions: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CupertinoActivityIndicator(radius: 8),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 20),
          tooltip: l10n.copyLink,
          onPressed: _copyLink,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget bottomBarBrowser(bool isDark, ColorScheme colors) {
    final l10n = context.l10n;
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
              NavIcon(
                icon: Icons.arrow_back_ios_new_rounded,
                enabled: _canGoBack,
                tooltip: l10n.back,
                onTap: () async {
                  if (await _controller.canGoBack()) _controller.goBack();
                },
              ),
              NavIcon(
                icon: Icons.arrow_forward_ios_rounded,
                enabled: _canGoForward,
                tooltip: l10n.forward,
                onTap: () async {
                  if (await _controller.canGoForward()) _controller.goForward();
                },
              ),
              NavIcon(
                icon: Icons.refresh_rounded,
                enabled: true,
                tooltip: l10n.refresh,
                onTap: () => _controller.reload(),
              ),
              NavIcon(
                icon: Icons.home_rounded,
                enabled: true,
                tooltip: l10n.backToArticle,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
