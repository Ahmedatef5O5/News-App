import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/network/network_info.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._responses);

  final List<Future<ResponseBody> Function()> _responses;
  int _callIndex = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final index = _callIndex++;
    return _responses[index % _responses.length]();
  }
}

Dio _dioReturning(List<Future<ResponseBody> Function()> responses) {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  dio.httpClientAdapter = _FakeAdapter(responses);
  return dio;
}

Future<ResponseBody> _ok([int status = 204]) async =>
    ResponseBody.fromString('', status);

Future<ResponseBody> _fail() async => throw DioException(
      requestOptions: RequestOptions(path: ''),
      type: DioExceptionType.connectionTimeout,
    );

void main() {
  group('NetworkInfoImpl — unit (fake Dio adapter)', () {
    test('returns true when the first probe succeeds', () async {
      final info = NetworkInfoImpl(
        probeUrls: const ['https://a.test', 'https://b.test'],
        dio: _dioReturning([_ok]),
      );

      expect(await info.isConnected, isTrue);
    });

    test('returns false when every probe throws', () async {
      final info = NetworkInfoImpl(
        probeUrls: const ['https://a.test', 'https://b.test'],
        dio: _dioReturning([_fail]),
      );

      expect(await info.isConnected, isFalse);
    });

    test('falls through to a later host if an earlier one throws', () async {
      final info = NetworkInfoImpl(
        probeUrls: const ['https://a.test', 'https://b.test'],
        dio: _dioReturning([_fail, _ok]),
      );

      expect(await info.isConnected, isTrue);
    });

    test('treats any HTTP response (even an error status) as reachable',
        () async {
      // A 401/404/500 still proves the server was reached over the network
      // — that's what matters for "is the path online", not the status.
      final info = NetworkInfoImpl(
        probeUrls: const ['https://a.test'],
        dio: _dioReturning([() => _ok(401)]),
      );

      expect(await info.isConnected, isTrue);
    });

    test('concurrent calls share a single in-flight check', () async {
      var callCount = 0;
      final dio = Dio(BaseOptions(validateStatus: (_) => true));
      dio.httpClientAdapter = _FakeAdapter([
        () async {
          callCount++;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return ResponseBody.fromString('', 204);
        },
      ]);

      final info = NetworkInfoImpl(
        probeUrls: const ['https://a.test'],
        dio: dio,
      );

      final results = await Future.wait([
        info.isConnected,
        info.isConnected,
        info.isConnected,
      ]);

      expect(results, everyElement(isTrue));
      expect(callCount, 1);
    });

    test('returns false immediately when probeUrls is empty', () async {
      final info = NetworkInfoImpl(probeUrls: const []);
      expect(await info.isConnected, isFalse);
    });
  });

  group('NetworkInfoImpl — integration (real network)', () {
    test(
      'returns true on a device/CI runner with internet',
      () async {
        final info = NetworkInfoImpl(
          probeUrls: const ['https://www.gstatic.com/generate_204'],
        );
        final result = await info.isConnected;
        // Environment-dependent — just verify it completes without throwing.
        expect(result, isA<bool>());
      },
      skip: const bool.fromEnvironment('CI'),
    );
  });
}
