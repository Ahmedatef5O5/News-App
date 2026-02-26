import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:news_app/core/utilities/theme/app_colors.dart';
import '../../../core/utilities/constants/app_images.dart';
import '../models/top_headlines_api_response.dart';
import '../widgets/custom_glass_container.dart';

class ArticleDetailsView extends StatefulWidget {
  const ArticleDetailsView({super.key, required this.article});
  final Article article;

  @override
  State<ArticleDetailsView> createState() => _ArticleDetailsViewState();
}

class _ArticleDetailsViewState extends State<ArticleDetailsView> {
  final ValueNotifier<double> _sheetPosition = ValueNotifier(0.5);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white70,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: _sheetPosition,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -value * 50),
                child: CachedNetworkImage(
                  imageUrl:
                      widget.article.urlToImage ?? AppImages.placeholderImg,
                  width: double.infinity,
                  height: size.height * 0.6,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          Container(
            height: size.height * 0.6,
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

          ValueListenableBuilder<double>(
            valueListenable: _sheetPosition,
            builder: (context, value, child) {
              double opacity = (1 - (value - 0.5) * 4).clamp(0.0, 1.0);
              return Positioned(
                top: size.height * ((0.35) - (value - 0.5) * 0.2),
                left: 8,
                right: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Opacity(
                    opacity: opacity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          widget.article.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
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
                              '●  ${widget.article.formattedDate}',
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
                  ),
                ),
              );
            },
          ),
          ValueListenableBuilder<double>(
            valueListenable: _sheetPosition,
            builder: (context, value, child) {
              double appBarOpacity = (1 - (value - 0.45) * 2.5).clamp(0.0, 1.0);

              return Opacity(
                opacity: appBarOpacity,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                  ),
                  child: Row(
                    children: [
                      const Gap(16),
                      CustomGlassContainer(
                        child: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: AppColors.whiteColor,
                        ),
                        onTap: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      CustomGlassContainer(
                        child: Icon(
                          Icons.favorite_border,
                          color: AppColors.whiteColor,
                        ),
                        onTap: () {},
                      ),
                      const Gap(8),
                      CustomGlassContainer(
                        child: Icon(
                          Icons.share_outlined,
                          color: AppColors.whiteColor,
                        ),
                        onTap: () {},
                      ),
                      const Gap(16),
                    ],
                  ),
                ),
              );
            },
          ),

          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              _sheetPosition.value = notification.extent;
              return true;
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.47,
              minChildSize: 0.46,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        // color: Colors.black.withOpacity(0.1),
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context).primaryColor,
                            backgroundImage: AssetImage(AppImages.news),
                          ),
                          Gap(16),
                          Text(
                            widget.article.source!.name ?? '',
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  fontSize: 20,
                                  color: AppColors.blackColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Gap(6),
                          Image.asset(AppImages.checked, width: 12, height: 12),
                        ],
                      ),
                      const Gap(20),
                      Text(
                        widget.article.description ??
                            'No Description Available...',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontSize: 18,
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Gap(20),
                      Text(
                        widget.article.content ?? 'Full content goes here...',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const Gap(20),
                      Text(
                        widget.article.content ?? 'Full content goes here...',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const Gap(25),
                      Text(
                        'authored by:',
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.black45,
                            ),
                      ),
                      Gap(10),
                      Row(
                        children: [
                          if (widget.article.author != null)
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  child: Icon(Icons.person),
                                ),
                                Gap(6),
                                Text(
                                  widget.article.shortAuthor ?? '',

                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.blackColor,
                                      ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Image.asset(
                                    AppImages.checked,
                                    width: 11,
                                    height: 11,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Gap(20),

                      Text(
                        'Published at:',
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.black45,
                            ),
                      ),
                      Gap(12),
                      Text(
                        '  ● ${widget.article.formattedDate}',
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackColor,
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
}
