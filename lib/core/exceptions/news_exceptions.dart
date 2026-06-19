import 'package:dio/dio.dart';

enum NewsErrorCode {
  offlineNoCache,
  networkTimeout,
  serverError,
  unauthorized,
  rateLimited,
  unknown,
}

sealed class NewsException implements Exception {
  const NewsException(this.code);
  final NewsErrorCode code;
}

final class OfflineNoCacheException extends NewsException {
  const OfflineNoCacheException() : super(NewsErrorCode.offlineNoCache);
}

final class NetworkTimeoutException extends NewsException {
  const NetworkTimeoutException() : super(NewsErrorCode.networkTimeout);
}

final class ServerException extends NewsException {
  const ServerException(this.statusCode) : super(NewsErrorCode.serverError);
  final int? statusCode;
}

NewsException mapDioError(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout =>
      const NetworkTimeoutException(),
    DioExceptionType.badResponse => ServerException(e.response?.statusCode),
    _ => const ServerException(null),
  };
}
