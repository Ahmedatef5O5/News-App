import 'dart:async';
import 'dart:io';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({
    Duration timeout = const Duration(seconds: 5),
    List<String>? hosts,
  })  : _timeout = timeout,
        _hosts = hosts ??
            const [
              'google.com',
              'cloudflare.com',
              'dns.google',
            ];

  final Duration _timeout;
  final List<String> _hosts;

  Future<bool>? _pending;

  @override
  Future<bool> get isConnected {
    _pending ??= _check().whenComplete(() => _pending = null);
    return _pending!;
  }

  Future<bool> _check() async {
    for (final host in _hosts) {
      try {
        final result = await InternetAddress.lookup(host).timeout(_timeout);
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
          return true;
        }
      } on SocketException {
        // This host unreachable — try the next one.
        continue;
      } on TimeoutException {
        // DNS timed out — try the next one.
        continue;
      } catch (_) {
        continue;
      }
    }
    // All hosts failed.
    return false;
  }
}
