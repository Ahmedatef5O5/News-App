import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:news_app/core/utilities/theme/app_colors.dart';
import 'package:news_app/core/widgets/article_widget_item.dart';
import 'package:news_app/features/favorites/favorite_cubit/favorite_cubit.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 40,
        title: Text(
          'Saved Articles',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: AppColors.blackColor,
            fontWeight: FontWeight.w400,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: SafeArea(
          child: Column(
            children: [
              Gap(12),
              BlocBuilder<FavoriteCubit, FavoriteState>(
                buildWhen: (previous, current) =>
                    current is FavoriteLoading ||
                    current is FavoriteLoaded ||
                    current is FavoriteError,
                builder: (context, state) {
                  if (state is FavoriteLoading) {
                    return Center(
                      child: CupertinoActivityIndicator(
                        color: AppColors.black12,
                      ),
                    );
                  } else if (state is FavoriteLoaded) {
                    if (state.articles.isEmpty) {
                      return Center(child: Text('No saved articles yet.'));
                    }
                    return Expanded(
                      child: ListView.builder(
                        itemCount: state.articles.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: ArticleWidgetItem(
                              article: state.articles[index],
                              author: state.articles[index].author,
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is FavoriteError) {
                    return Center(child: Text(state.errMsg));
                  } else {
                    // return const Center(
                    //   child: Text('Something went wrong'),
                    // );
                    // return SizedBox.shrink();
                    return SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.78,
                      child: Center(
                        child: Text(
                          'No saved articles yet.',
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
                                color: AppColors.black45,
                                fontWeight: FontWeight.w300,
                                fontSize: 22,
                              ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
