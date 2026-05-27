import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_loading_indicator.dart';
import '../cubit/search_cubit.dart';

class SearchInputFieldArea extends StatelessWidget {
  const SearchInputFieldArea({
    super.key,
    required TextEditingController controller,
    required FocusNode focus,
    required this.tt,
  })  : _controller = controller,
        _focus = focus;

  final TextEditingController _controller;
  final FocusNode _focus;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focus,
      onChanged: (q) => context.read<SearchCubit>().onQueryChanged(q),
      style: tt.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Search articles, topics, sources…',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.ink300),
        suffixIcon: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (state.status == SearchStatus.loading) {
              return const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CustomLoadingIndicator(),
                ),
              );
            }
            if (_controller.text.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.ink300),
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
    );
  }
}
