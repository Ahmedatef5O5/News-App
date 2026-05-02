import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/models/article_model.dart';

import '../services/search_services.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({SearchService? service})
      : _service = service ?? SearchService(),
        super(const SearchState());

  final SearchService _service;
  Timer? _debounce;

  /// Called on every keystroke — debounced by 500ms.
  void onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      emit(const SearchState());
      return;
    }
    emit(state.copyWith(query: query, status: SearchStatus.loading));
    _debounce = Timer(AppConstants.searchDebounce, () => _search(query));
  }

  Future<void> _search(String query) async {
    try {
      final result = await _service.search(query: query.trim());
      emit(state.copyWith(
        status: SearchStatus.success,
        results: result.articles,
        totalResults: result.totalResults,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.failure,
        error: e.toString(),
      ));
    }
  }

  /// Manual retry.
  Future<void> retry() async {
    if (state.query.isEmpty) return;
    emit(state.copyWith(status: SearchStatus.loading, error: null));
    await _search(state.query);
  }

  void clear() {
    _debounce?.cancel();
    emit(const SearchState());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
