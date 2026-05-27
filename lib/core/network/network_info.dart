import 'dart:async';
import 'dart:io';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({
    Duration timeout = const Duration(seconds: 2),
    List<String>? hosts,
  })  : _timeout = timeout,
        _hosts = hosts ??
            const [
              'google.com',
              'cloudflare.com',
              'bing.com',
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
    final completer = Completer<bool>();
    int failed = 0;

    for (final host in _hosts) {
      _checkHost(host).then((isUp) {
        if (isUp && !completer.isCompleted) {
          completer.complete(true);
        } else if (!isUp) {
          failed++;
          if (failed == _hosts.length && !completer.isCompleted) {
            completer.complete(false);
          }
        }
      });
    }

    return completer.future;
  }

  Future<bool> _checkHost(String host) async {
    try {
      final socket = await Socket.connect(host, 443, timeout: _timeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}
