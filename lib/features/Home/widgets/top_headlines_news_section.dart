import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/utilities/theme/app_colors.dart';
import 'package:news_app/features/Home/widgets/custom_carousel_item.dart';
import 'package:news_app/features/Home/widgets/top_headers_carousel_slider.dart';
import '../cubit/home_cubit.dart';

class TopHeadlinesNewsSection extends StatelessWidget {
  const TopHeadlinesNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          current is TopHeadlinesLoading ||
          current is TopHeadlinesSuccessLoaded ||
          current is TopHeadlinesError,
      builder: (context, state) {
        if (state is TopHeadlinesLoading) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: CupertinoActivityIndicator(color: AppColors.black12),
            ),
          );
        } else if (state is TopHeadlinesSuccessLoaded) {
          final articles = state.articles;
          if (articles == null) {
            return const Center(child: Text('No articles Found'));
          }
          return CustomCarouselSlider(
            items: articles
                .map(
                  (singleArticle) => CustomCarouselItem(
                    article: singleArticle,
                    category: singleArticle.source?.name,
                  ),
                )
                .toList(),
          );
        } else if (state is TopHeadlinesError) {
          return Center(child: Text(state.errMsg));
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
