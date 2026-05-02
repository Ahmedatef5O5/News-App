import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/theme/app_colors.dart';
import '../../../core/helpers/empty_state.dart';
import '../../../core/helpers/error_state.dart';
import '../../../core/helpers/shimmer_box.dart';
import '../../../core/widgets/article_card_widget.dart';
import '../Search_cubit/search_cubit.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: false,
        leadingWidth: 48,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              onChanged: (q) => context.read<SearchCubit>().onQueryChanged(q),
              style: tt.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search articles, topics, sources…',
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppColors.ink300),
                suffixIcon: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    if (state.status == SearchStatus.loading) {
                      return const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }
                    if (_controller.text.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.ink300),
                        onPressed: () {
                          _controller.clear();
                          context.read<SearchCubit>().clear();
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                return switch (state.status) {
                  SearchStatus.initial => _InitialHint(),
                  SearchStatus.loading => _LoadingSkeleton(),
                  SearchStatus.success => _ResultsList(state: state),
                  SearchStatus.failure => ErrorState(
                      message: state.error ?? 'Search failed',
                      onRetry: () => context.read<SearchCubit>().retry(),
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.search_rounded,
      title: 'Search for news',
      subtitle: 'Find articles by title, topic, or keyword',
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (_, __) => const ArticleCardSkeleton(),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.state});
  final SearchState state;

  @override
  Widget build(BuildContext context) {
    if (state.results.isEmpty) {
      return EmptyState(
        icon: Icons.article_outlined,
        title: 'No results found',
        subtitle: 'Try different keywords or check your spelling.',
      );
    }

    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text(
            '${state.totalResults} results',
            style: tt.bodySmall?.copyWith(
              color: AppColors.ink300,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.results.length,
            itemBuilder: (ctx, index) {
              final article = state.results[index];
              return ArticleCard(
                article: article,
                onTap: () => Navigator.of(ctx).pushNamed(
                  AppRoutes.artcileDetailsRoute,
                  arguments: article,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
