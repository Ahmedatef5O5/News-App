import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/models/article_model.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/widgets/save_button_widget.dart';
import 'package:news_app/core/widgets/share_button_widget.dart';
import 'package:news_app/l10n/app_localizations_x.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.heroContext = 'list',
  });

  final Article article;
  final VoidCallback onTap;
  final String heroContext;

  String get heroTag => 'article-image-${article.uniqueId}-$heroContext';

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    // RTL detection to mirror thumbnail corners so image always sits on "start" edge
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink900.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Thumbnail with Hero ──────────────────────────────────────
              Hero(
                tag: heroTag,
                flightShuttleBuilder: _flightShuttleBuilder,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: isRtl ? Radius.zero : const Radius.circular(20),
                    bottomLeft: isRtl ? Radius.zero : const Radius.circular(20),
                    topRight: isRtl ? const Radius.circular(20) : Radius.zero,
                    bottomRight:
                        isRtl ? const Radius.circular(20) : Radius.zero,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: article.hasImage
                        ? article.urlToImage!
                        : AppConstants.placeholderImageUrl,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 110,
                      height: 110,
                      color: AppColors.shimmer,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 110,
                      height: 110,
                      color: AppColors.shimmer,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.ink300,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Text content ─────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.source?.name ?? context.l10n.unknownSource,
                        style: txtTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.title ?? context.l10n.untitled,
                        style: txtTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              article.formattedDate,
                              style: txtTheme.bodySmall?.copyWith(fontSize: 11),
                              maxLines: 1,
                            ),
                          ),
                          ShareButton(article: article),
                          const SizedBox(width: 4),
                          SaveButton(article: article, size: 32),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
        final isRtl = Directionality.of(flightContext) == TextDirection.rtl;

        final startRadius = BorderRadius.only(
          topLeft: isRtl ? Radius.zero : const Radius.circular(20),
          bottomLeft: isRtl ? Radius.zero : const Radius.circular(20),
          topRight: isRtl ? const Radius.circular(20) : Radius.zero,
          bottomRight: isRtl ? const Radius.circular(20) : Radius.zero,
        );
        final radius = BorderRadius.lerp(
          startRadius,
          BorderRadius.zero,
          t,
        )!;
        return ClipRRect(
          borderRadius: radius,
          child: CachedNetworkImage(
            imageUrl: article.hasImage
                ? article.urlToImage!
                : AppConstants.placeholderImageUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
