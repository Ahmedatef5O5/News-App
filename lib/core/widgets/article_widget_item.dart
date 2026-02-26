import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../features/Home/models/top_headlines_api_response.dart';
import '../utilities/constants/app_images.dart';
import '../utilities/theme/app_colors.dart';

class ArticleWidgetItem extends StatelessWidget {
  const ArticleWidgetItem({
    super.key,
    required this.article,
    required this.author,
  });

  final Article? article;
  final String? author;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: article?.urlToImage ?? AppImages.placeholderImg,
              placeholder: (context, url) =>
                  CupertinoActivityIndicator(color: AppColors.black12),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: 130,
              height: 125,
              fit: BoxFit.cover,
            ),
          ),
          Gap(12),
          Expanded(
            child: SizedBox(
              height: 125,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    article?.source!.name ?? 'No source',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey7Color,
                    ),
                  ),
                  Text(
                    article?.title ?? 'No title',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                  ),

                  Row(
                    children: [
                      if (author != null)
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Image.asset(
                                AppImages.checked,
                                width: 10,
                                height: 10,
                              ),
                            ),
                            Text(
                              article?.shortAuthor ?? '',

                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.grey5Color,
                                  ),
                            ),
                            Gap(8),
                          ],
                        ),

                      Text(
                        '● ${article?.formattedDate}',
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey5Color,
                            ),
                      ),
                    ],
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
