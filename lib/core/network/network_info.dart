import 'dart:async';
import 'package:dio/dio.dart';
import 'package:news_app/core/constants/app_constants.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// HTTP-based connectivity check.

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({
    Duration timeout = const Duration(seconds: 4),
    List<String>? probeUrls,
    Dio? dio,
  })  : _timeout = timeout,
        _probeUrls = probeUrls ??
            [
              AppConstants.baseUrl,
              'https://www.gstatic.com/generate_204',
              'https://cloudflare.com/cdn-cgi/trace',
            ],
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: timeout,
              receiveTimeout: timeout,
              validateStatus: (_) => true,
            ));

  final Duration _timeout;
  final List<String> _probeUrls;
  final Dio _dio;

  Future<bool>? _pending;

  @override
  Future<bool> get isConnected {
    _pending ??= _check().whenComplete(() => _pending = null);
    return _pending!;
  }

  Future<bool> _check() async {
    if (_probeUrls.isEmpty) return false;

    final completer = Completer<bool>();
    int failed = 0;

    for (final url in _probeUrls) {
      _probe(url).then((isUp) {
        if (completer.isCompleted) return;
        if (isUp) {
          completer.complete(true);
        } else {
          failed++;
          if (failed == _probeUrls.length) completer.complete(false);
        }
      });
    }

    return completer.future;
  }

  Future<bool> _probe(String url) async {
    try {
      final response = await _dio.get(url);
      return response.statusCode != null;
    } catch (_) {
      return false;
    }
  }
}
