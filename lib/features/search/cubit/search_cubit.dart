import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/models/article_model.dart';
import '../../../core/locale/locale_cubit.dart';
import '../../../core/pagination/model/pagination_meta.dart';
import '../services/search_services.dart';
part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required SearchService service,
    required LocaleCubit localeCubit,
  })  : _service = service,
        _locale = localeCubit,
        super(const SearchState()) {
    _localeSubscription = _locale.stream.listen(_onLocaleChanged);
  }

  final SearchService _service;
  final LocaleCubit _locale;
  StreamSubscription<Locale>? _localeSubscription;

  Timer? _debounce;

  /// Called on every keystroke — debounced by 500ms.
  void onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      emit(const SearchState());
      return;
    }
    emit(state.copyWith(
      query: query,
      status: SearchStatus.loading,
      clearError: true,
    ));
    _debounce = Timer(
      AppConstants.searchDebounce,
      () => _fetchPage(query.trim(), 1, SearchStatus.loading),
    );
  }
// ── Pagination ─────────────────────────────────────────────────────────────

  Future<void> goToPage(int page) async {
    if (page == state.pagination.currentPage) return;
    if (state.query.isEmpty) return;
    await _fetchPage(state.query, page, SearchStatus.loadingPage);
  }

  Future<void> goToNextPage() => goToPage(state.pagination.nextPage);
  Future<void> goToPreviousPage() => goToPage(state.pagination.previousPage);

  Future<void> retry() async {
    if (state.query.isEmpty) return;
    await _fetchPage(
      state.query,
      state.pagination.currentPage,
      SearchStatus.loading,
    );
  }

  void clear() {
    _debounce?.cancel();
    emit(const SearchState());
  }

  // ── Core fetch ─────────────────────────────────────────────────────────────

  void _onLocaleChanged(Locale _) {
    if (state.query.isNotEmpty) {
      _fetchPage(state.query, 1, SearchStatus.loading);
    }
  }

  Future<void> _fetchPage(
    String query,
    int page,
    SearchStatus loadingStatus,
  ) async {
    emit(state.copyWith(status: loadingStatus, clearError: true));
    try {
      final result = await _service.search(
        query: query,
        page: page,
        pageSize: AppConstants.searchPageSize,
        language: _locale.state.languageCode,
      );

      final newPagination = state.pagination.copyWith(
        currentPage: page,
        totalResults: result.totalResults,
        pageSize: AppConstants.searchPageSize,
      );

      emit(state.copyWith(
        status: SearchStatus.success,
        results: result.articles,
        pagination: newPagination,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.failure,
        error: e,
      ));
    }
  }

  @override
  Future<void> close() {
    _localeSubscription?.cancel();
    _debounce?.cancel();
    return super.close();
  }
}
