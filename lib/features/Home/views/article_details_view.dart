import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:news_app/core/utilities/theme/app_colors.dart';
import '../../../core/utilities/constants/app_images.dart';
import '../models/top_headlines_api_response.dart';
import '../widgets/custom_glass_container.dart';

class ArticleDetailsView extends StatelessWidget {
  const ArticleDetailsView({super.key, required this.article});
  final Article article;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: CustomGlassContainer(
            child: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: AppColors.whiteColor,
            ),
            onTap: () => Navigator.pop(context),
          ),
        ),
        actionsPadding: EdgeInsets.only(right: 8),
        actions: [
          CustomGlassContainer(
            child: Icon(Icons.favorite_border, color: AppColors.whiteColor),
            onTap: () {},
          ),
          Gap(8),
          CustomGlassContainer(
            child: Icon(Icons.share_outlined, color: AppColors.whiteColor),
            onTap: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: article.urlToImage ?? AppImages.placeholderImg,
            width: double.infinity,
            height: size.height * 0.5,
            fit: BoxFit.cover,
          ),
          Container(
            height: size.height * 0.5,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                end: Alignment.center,
                begin: Alignment.bottomCenter,
                colors: [
                  AppColors.black12!.withValues(alpha: 0.75),
                  AppColors.black12!.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.32,
            left: 8,
            right: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.rectangle,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(18),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            'General',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        ),
                      ),
                      Gap(5),
                      Text(
                        article.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Gap(5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Trending',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                          ),
                          Gap(12),
                          Text(
                            '●  ${article.formattedDate}',
                            style: Theme.of(context).textTheme.labelMedium!
                                .copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.grey2Color,
                                ),
                          ),
                        ],
                      ),
                      Gap(16),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.blackColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'data',
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'data',
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'data',
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'data',
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'data',
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
