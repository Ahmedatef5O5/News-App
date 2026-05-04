import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/models/article_model.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/widgets/share_button_widget.dart';
import 'save_button_widget.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

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
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
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
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: AppColors.ink300),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source name
                      Text(
                        article.source?.name ?? 'Unknown Source',
                        style: tt.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Title
                      Text(
                        article.title ?? 'Untitled',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Meta row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              article.formattedDate,
                              style: tt.bodySmall?.copyWith(fontSize: 11),
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
}
