import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/widgets/custom_app_bar_icon.dart';
import '../../../core/helpers/empty_state.dart';
import '../../../core/helpers/error_state.dart';
import '../../../core/helpers/shimmer_box.dart';
import '../Search_cubit/search_cubit.dart';
import '../widgets/results_with_bar_widget.dart';
import '../widgets/search_input_field_area.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

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
        title: const Text('Search'),
        centerTitle: false,
        leadingWidth: 42,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchInputFieldArea(
                controller: _controller, focus: _focus, tt: tt),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocConsumer<SearchCubit, SearchState>(
              listenWhen: (prev, curr) =>
                  prev.pagination.currentPage != curr.pagination.currentPage &&
                  curr.status == SearchStatus.success,
              listener: (_, __) => _scrollToTop(),
              builder: (context, state) {
                return switch (state.status) {
                  SearchStatus.initial => _InitialHint(),
                  SearchStatus.loading => _LoadingSkeleton(),
                  SearchStatus.loadingPage => _LoadingSkeleton(),
                  SearchStatus.loadingMore => ResultsWithBar(
                      state: state,
                      scrollController: _scrollController,
                      onPageTap: (p) {
                        context.read<SearchCubit>().goToPage(p);
                        _scrollToTop();
                      },
                      onPrev: () {
                        context.read<SearchCubit>().goToPreviousPage();
                        _scrollToTop();
                      },
                      onNext: () {
                        context.read<SearchCubit>().goToNextPage();
                        _scrollToTop();
                      },
                    ),
                  SearchStatus.success => state.results.isEmpty
                      ? _EmptyResults()
                      : ResultsWithBar(
                          state: state,
                          scrollController: _scrollController,
                          onPageTap: (p) {
                            context.read<SearchCubit>().goToPage(p);
                            _scrollToTop();
                          },
                          onPrev: () {
                            context.read<SearchCubit>().goToPreviousPage();
                            _scrollToTop();
                          },
                          onNext: () {
                            context.read<SearchCubit>().goToNextPage();
                            _scrollToTop();
                          },
                        ),
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

class _EmptyResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.article_outlined,
      title: 'No results found',
      subtitle: 'Try different keywords or check your spelling.',
    );
  }
}
