import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/di/service_locator.dart';
import 'package:news_app/core/helpers/empty_state.dart';
import 'package:news_app/core/helpers/error_state.dart';
import 'package:news_app/core/helpers/shimmer_box.dart';
import 'package:news_app/core/widgets/custom_app_bar_icon.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../cubit/search_cubit.dart';
import '../widgets/results_with_bar_widget.dart';
import '../widgets/search_input_field_area.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchCubit>(
      create: (_) => sl<SearchCubit>(),
      child: const _SearchContent(),
    );
  }
}

class _SearchContent extends StatefulWidget {
  const _SearchContent();

  @override
  State<_SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<_SearchContent> {
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
    final txtTheme = Theme.of(context).textTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final l10n = context.l10n;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsetsDirectional.only(start: 8.0),
            child: CustomAppBarIcon(
              icon: isRtl
                  ? CupertinoIcons.chevron_forward
                  : CupertinoIcons.chevron_back,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          title: Text(l10n.searchForNews),
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
                controller: _controller,
                focus: _focus,
                txtTheme: txtTheme,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocConsumer<SearchCubit, SearchState>(
                listenWhen: (prev, curr) =>
                    prev.pagination.currentPage !=
                        curr.pagination.currentPage &&
                    curr.status == SearchStatus.success,
                listener: (_, __) => _scrollToTop(),
                builder: (context, state) {
                  return switch (state.status) {
                    SearchStatus.initial => const _InitialHint(),
                    SearchStatus.loading => const _LoadingSkeleton(),
                    SearchStatus.loadingPage => const _LoadingSkeleton(),
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
                        ? const _EmptyResults()
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
                        message: state.error ?? l10n.searchFailed,
                        onRetry: () => context.read<SearchCubit>().retry(),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private helper widgets ─────────────────────────────────────────────────────

class _InitialHint extends StatelessWidget {
  const _InitialHint();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return EmptyState(
      icon: Icons.search_rounded,
      title: l10n.searchForNews,
      subtitle: l10n.searchHintSubtitle,
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

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
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return EmptyState(
      icon: Icons.article_outlined,
      title: l10n.noResultsFound,
      subtitle: l10n.noResultsSubtitle,
    );
  }
}
