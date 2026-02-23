import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:news_app/features/Home/cubit/home_cubit.dart';
import 'package:news_app/features/Home/widgets/top_headers_carousel_slider.dart';
import '../widgets/custom_carousel_item.dart';
import '../widgets/title_headline_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final homeCubit = HomeCubit();
        homeCubit.getTopHeadlines();
        return homeCubit;
      },
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TitleHeadlineWidget(
                  title: 'Breaking News',
                  txtBtn: 'View all',
                  wordSpacing: -2,
                  onTap: () {},
                ),
                Gap(16),
                BlocBuilder<HomeCubit, HomeState>(
                  bloc: BlocProvider.of<HomeCubit>(context),
                  buildWhen: (previous, current) =>
                      current is TopHeadlinesLoading ||
                      current is TopHeadlinesSuccessLoaded ||
                      current is TopHeadlinesError,
                  builder: (context, state) {
                    if (state is TopHeadlinesLoading) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: Center(
                          child: CupertinoActivityIndicator(
                            color: Colors.black12,
                          ),
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
                ),
                Gap(22),
                TitleHeadlineWidget(
                  title: 'Recommendation',

                  txtBtn: 'View all',
                  wordSpacing: -2,
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
