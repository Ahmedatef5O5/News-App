import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app/core/browser/in_app_browser_view.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/models/article_model.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/widgets/save_button_widget.dart';

class ArticleDetailView extends StatefulWidget {
  const ArticleDetailView({
    super.key,
    required this.article,
    this.heroTag,
  });

  final Article article;
  final String? heroTag;

  @override
  State<ArticleDetailView> createState() => _ArticleDetailViewState();
}

class _ArticleDetailViewState extends State<ArticleDetailView> {
  final ValueNotifier<double> _sheetExtent = ValueNotifier(0.48);

  String get _heroTag =>
      widget.heroTag ?? 'article-image-${widget.article.uniqueId}';

  @override
  void dispose() {
    _sheetExtent.dispose();
    super.dispose();
  }

  void _openInAppBrowser() {
    if (!widget.article.hasUrl) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => InAppBrowserView(
          url: widget.article.url!,
          title: widget.article.title ?? 'Article',
        ),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  Future<void> _share() async {
    final text = '${widget.article.title}\n\n${widget.article.url ?? ""}';
    await Clipboard.setData(ClipboardData(text: text));
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          // ── Hero background image ──────────────────────────────────────
          ValueListenableBuilder<double>(
            valueListenable: _sheetExtent,
            builder: (_, extent, child) {
              final parallax = (extent - 0.48).clamp(0.0, 1.0) * 60;
              return Transform.translate(
                offset: Offset(0, -parallax),
                child: child,
              );
            },
            child: Hero(
              tag: _heroTag,
              flightShuttleBuilder: _flightShuttleBuilder,
              child: CachedNetworkImage(
                imageUrl: widget.article.hasImage
                    ? widget.article.urlToImage!
                    : AppConstants.placeholderImageUrl,
                width: double.infinity,
                height: size.height * 0.55,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.surfaceDark),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.surfaceDark),
              ),
            ),
          ),

          // ── Gradient on image ──────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),

          // ── AppBar overlay ─────────────────────────────────────────────
          ValueListenableBuilder<double>(
            valueListenable: _sheetExtent,
            builder: (_, extent, __) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final opacity = (1.0 - (extent - 0.45) * 5.0).clamp(0.0, 1.0);
              return Opacity(
                opacity: opacity,
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _GlassButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        SaveButton(
                          article: widget.article,
                          size: 42,
                          isGlass: true,
                          iconColor: isDark ? Colors.white : AppColors.ink700,
                        ),
                        const SizedBox(width: 8),
                        _GlassButton(
                          icon: Icons.share_outlined,
                          onTap: _share,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Draggable sheet ────────────────────────────────────────────
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (n) {
              _sheetExtent.value = n.extent;
              return true;
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.48,
              minChildSize: 0.47,
              maxChildSize: 0.96,
              builder: (_, scrollController) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final colors = Theme.of(context).colorScheme;

                return Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      // Drag handle
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white24 : AppColors.ink100,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Source row
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primary,
                                  child: Icon(Icons.language_rounded,
                                      color: colors.onSurface, size: 16),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.article.source?.name ?? 'Unknown',
                                    style: tt.titleMedium?.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.verified_rounded,
                                    color: AppColors.primary, size: 18),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Category badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.article.source?.name ?? 'General',
                                style: tt.labelSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Headline
                            Text(
                              widget.article.title ?? '',
                              style: tt.headlineMedium?.copyWith(
                                fontSize: 20,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Meta
                            Row(
                              children: [
                                if (widget.article.shortAuthor != null) ...[
                                  const Icon(Icons.person_outline,
                                      size: 14, color: AppColors.ink300),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.article.shortAuthor!,
                                    style: tt.bodySmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                const Icon(Icons.schedule_outlined,
                                    size: 14, color: AppColors.ink300),
                                const SizedBox(width: 4),
                                Text(
                                  widget.article.formattedDate,
                                  style: tt.bodySmall,
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 20),

                            // Description
                            Text(
                              widget.article.cleanDescription,
                              style: tt.bodyLarge?.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.85),
                                height: 1.7,
                              ),
                            ),

                            // Content
                            if (widget.article.cleanContent.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                widget.article.cleanContent,
                                style: tt.bodyMedium?.copyWith(
                                  color:
                                      colors.onSurface.withValues(alpha: 0.7),
                                  height: 1.7,
                                ),
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Read Full Article CTA
                            if (widget.article.hasUrl)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _openInAppBrowser,
                                  icon:
                                      const Icon(Icons.open_in_browser_rounded),
                                  label: const Text('Read Full Article'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    textStyle: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 12),

                            // Share button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _share,
                                icon: const Icon(Icons.share_outlined),
                                label: const Text('Share Article'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.onSurface,
                                  side: BorderSide(color: colors.outline),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  textStyle: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final t = direction == HeroFlightDirection.push
            ? animation.value
            : 1 - animation.value;
        return ClipRRect(
          borderRadius: BorderRadius.lerp(
            BorderRadius.circular(24),
            BorderRadius.zero,
            t,
          )!,
          child: CachedNetworkImage(
            imageUrl: widget.article.hasImage
                ? widget.article.urlToImage!
                : AppConstants.placeholderImageUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

// ── Glass button ───────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.3),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.white24,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white : AppColors.ink700,
            ),
          ),
        ),
      ),
    );
  }
}
