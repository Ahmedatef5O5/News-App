import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:news_app/core/models/news_api_response.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/utilities/theme/app_colors.dart';
import 'package:news_app/core/widgets/article_widget_item.dart';
import 'package:news_app/features/search/Search_cubit/search_cubit.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final searchCubit = BlocProvider.of<SearchCubit>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Search'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          children: [
            Gap(12),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by title',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: BlocBuilder<SearchCubit, SearchState>(
                  bloc: searchCubit,
                  buildWhen: (previous, current) =>
                      current is SearchResultsSuccessLoaded ||
                      current is SearchResultsLoading ||
                      current is SearchResultsError,
                  builder: (context, state) {
                    if (state is SearchResultsLoading) {
                      return CupertinoActivityIndicator(
                        color: AppColors.primaryColor,
                      );

                      // return TextButton(onPressed: null, child: Text('Search'));
                    }
                    return TextButton(
                      onPressed: () async =>
                          await searchCubit.search(searchController.text),
                      child: Text('Search'),
                    );
                  },
                ),
              ),
            ),
            Gap(12),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                bloc: searchCubit,
                buildWhen: (previous, current) =>
                    current is SearchResultsSuccessLoaded ||
                    current is SearchResultsLoading ||
                    current is SearchResultsError,
                builder: (context, state) {
                  if (state is SearchResultsLoading) {
                    return Center(
                      child: CupertinoActivityIndicator(
                        color: AppColors.black12,
                      ),
                    );
                  } else if (state is SearchResultsSuccessLoaded) {
                    final articles = state.articles;
                    if (articles.isEmpty) {
                      return Center(
                        child: Text(
                          'No articles found',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                color: AppColors.grey5Color,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.artcileDetailsView,
                            arguments: article,
                          ),
                          child: ArticleWidgetItem(
                            article: article,
                            author: article.shortAuthor ?? '',
                          ),
                        );
                      },
                    );
                  } else if (state is SearchResultsError) {
                    return Center(child: Text(state.errMsg));
                  } else {
                    return Center(
                      child: Text(
                        'Search for articles',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: AppColors.grey5Color,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    );

                    // return SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
