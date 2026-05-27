import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/router/app_routes.dart';
import '../../../core/helpers/empty_state.dart';
import '../../../core/helpers/error_state.dart';
import '../../../core/helpers/shimmer_box.dart';
import '../../../core/models/article_detail_args.dart';
import '../../../core/widgets/article_card_widget.dart';
import '../../../core/widgets/custom_app_bar_icon.dart';
import '../cubit/favorite_cubit.dart';
import '../cubit/favorite_state.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CustomAppBarIcon(
            icon: CupertinoIcons.chevron_back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        title: const Text('Saved Articles'),
        centerTitle: false,
        leadingWidth: 42,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          return switch (state.status) {
            FavStatus.initial || FavStatus.loading => const _LoadingSkeleton(),
            FavStatus.failure => ErrorState(
                message: state.error ?? 'Failed to load saved articles',
                onRetry: () => context.read<FavoritesCubit>().loadFavorites(),
              ),
            FavStatus.success => state.articles.isEmpty
                ? const EmptyState(
                    icon: Icons.bookmark_outline_rounded,
                    title: 'No saved articles',
                    subtitle:
                        'Tap the bookmark icon on any article to save it for later.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: state.articles.length,
                    itemBuilder: (ctx, index) {
                      final article = state.articles[index];
                      const heroContext = 'favorites';
                      final heroTag =
                          'article-image-${article.uniqueId}-$heroContext';
                      return ArticleCard(
                        article: article,
                        heroContext: heroContext,
                        onTap: () => Navigator.of(ctx).pushNamed(
                          AppRoutes.artcileDetailsRoute,
                          arguments: ArticleDetailArgs(
                              article: article, heroTag: heroTag),
                        ),
                      );
                    },
                  ),
          };
        },
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 5,
      itemBuilder: (_, __) => const ArticleCardSkeleton(),
    );
  }
}
