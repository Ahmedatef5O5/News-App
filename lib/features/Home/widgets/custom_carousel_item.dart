import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:news_app/core/utilities/constants/app_images.dart';
import 'package:news_app/core/utilities/theme/app_colors.dart';
import 'package:news_app/features/Home/models/top_headlines_api_response.dart';

class CustomCarouselItem extends StatelessWidget {
  const CustomCarouselItem({
    super.key,
    required this.article,
    this.category,
    this.publisher,
    this.date,
  });
  final Article article;
  final String? category;
  final String? publisher, date;

  @override
  Widget build(BuildContext context) {
    final DateTime? rawDate = DateTime.parse(
      article.publishedAt ?? DateTime.now().toString(),
    );
    final publishedDate = rawDate != null
        ? DateFormat.yMMMd().format(rawDate)
        : DateFormat.yMMMd().format(DateTime.now());

    String authorName = article.author ?? "No author";
    if (article.author != null && article.author!.isNotEmpty) {
      String cleanAuthorName = article.author!.replaceAll(',', '').trim();

      List<String> words = cleanAuthorName.split(' ');

      if (words.length > 2) {
        authorName = '${words[0]} ${words[1]}';
      }
    }

    return Container(
      clipBehavior: Clip.antiAlias,

      decoration: BoxDecoration(
        color: AppColors.grey5Color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: article.urlToImage ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CupertinoActivityIndicator(color: Colors.black12),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          Positioned(
            top: 1,
            left: 1,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black12.withAlpha(1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Text(
                    category ?? 'News',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black12.withAlpha(1),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.author != null && article.author!.isNotEmpty)
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            authorName,
                            // article.author ?? "No author",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        article.author != null
                            ? Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Image.asset(
                                  AppImages.checked,
                                  width: 14,
                                  height: 14,
                                ),
                              )
                            : SizedBox.shrink(),
                        Gap(12),
                        Text(
                          '●  $publishedDate',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                  Gap(2),
                  Text(
                    article.title ?? "No title",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
