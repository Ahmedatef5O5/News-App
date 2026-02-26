import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/features/Home/cubit/home_cubit.dart';
import 'package:news_app/features/Home/models/top_headlines_api_response.dart';
import '../../../core/utilities/theme/app_colors.dart';
import '../../../core/widgets/article_widget_item.dart';

class RecommendationNewsListView extends StatelessWidget {
  const RecommendationNewsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          BlocBuilder<HomeCubit, HomeState>(
            buildWhen: (previous, current) =>
                current is RecommendedNewsLoading ||
                current is RecommendedNewsLoaded ||
                current is RecommendedNewsError,
            builder: (context, state) {
              if (state is RecommendedNewsLoading) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Center(
                    child: CupertinoActivityIndicator(color: AppColors.black12),
                  ),
                );
              } else if (state is RecommendedNewsLoaded) {
                final articlesList = state.articles;
                return ListView.builder(
                  itemCount: articlesList?.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final article = articlesList?[index];
                    final author = article?.shortAuthor;
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.artcileDetailsView,
                        arguments: article,
                      ),
                      child: ArticleWidgetItem(
                        article: article,
                        author: author,
                      ),
                    );
                  },
                );
              } else if (state is RecommendedNewsError) {
                return Center(child: Text(state.errMsg));
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
