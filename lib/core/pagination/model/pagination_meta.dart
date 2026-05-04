// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import '../../constants/app_constants.dart';

/// Immutable pagination metadata.
/// Single source of truth for all pagination state.

class PaginationMeta extends Equatable {
  final int currentPage;
  final int totalResults;
  final int pageSize;

  const PaginationMeta({
    this.currentPage = 1,
    this.totalResults = 0,
    this.pageSize = AppConstants.recommendedPageSize,
  });

  int get totalPages {
    if (totalResults == 0) return 1;
    final effectiveTotal = totalResults.clamp(0, AppConstants.maxApiResults);
    return (effectiveTotal / pageSize).ceil().clamp(1, 999);
  }

  bool get isFirstPage => currentPage == 1;
  bool get isLastPage => currentPage >= totalPages;
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;

  int get nextPage => hasNextPage ? currentPage + 1 : currentPage;
  int get previousPage => hasPreviousPage ? currentPage - 1 : currentPage;

  List<int> get pageWindow {
    if (totalPages <= AppConstants.paginationWindowSize) {
      return List.generate(totalPages, (i) => i + 1);
    }

    int start = currentPage - AppConstants.paginationWindowSize ~/ 2;
    int end = currentPage + AppConstants.paginationWindowSize - 1;

    // clamp to valid range
    if (start < 1) {
      start = 1;
      end = AppConstants.paginationWindowSize;
    }
    if (end > totalPages) {
      end = totalPages;
      start = end - AppConstants.paginationWindowSize + 1;
    }
    return List.generate(end - start + 1, (i) => start + i);
  }

  PaginationMeta copyWith({
    int? currentPage,
    int? totalResults,
    int? pageSize,
  }) {
    return PaginationMeta(
      currentPage: currentPage ?? this.currentPage,
      totalResults: totalResults ?? this.totalResults,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [currentPage, totalResults, pageSize];

  @override
  String toString() =>
      'PaginationMeta(page: $currentPage/$totalPages, results: $totalResults, pageSize: $pageSize)';
}
