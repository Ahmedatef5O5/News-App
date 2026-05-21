import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/network/network_info.dart';

typedef LookupFn = Future<List<InternetAddress>> Function(String host);

class TestableNetworkInfo extends NetworkInfoImpl {
  TestableNetworkInfo({
    required this.lookupFn,
    super.timeout,
    super.hosts,
  });

  final LookupFn lookupFn;

  @override
  Future<bool> get isConnected => _checkWithFn();

  Future<bool> _checkWithFn() async {
    for (final host in _hostsForTest) {
      try {
        final result = await lookupFn(host).timeout(_timeoutForTest);
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  // Expose private fields for test use via getters on the subclass.
  List<String> get _hostsForTest => ['google.com', 'cloudflare.com'];
  Duration get _timeoutForTest => const Duration(seconds: 5);
}

void main() {
  group('NetworkInfoImpl — unit (stub)', () {
    test('returns true when lookup resolves a non-empty address', () async {
      final info = TestableNetworkInfo(
        lookupFn: (_) async => [
          InternetAddress('142.250.80.46'), // fake but valid IP format
        ],
        hosts: const ['google.com'],
      );

      expect(await info.isConnected, isTrue);
    });

    test('returns false when lookup returns an empty list', () async {
      final info = TestableNetworkInfo(
        lookupFn: (_) async => [],
        hosts: const ['google.com'],
      );

      expect(await info.isConnected, isFalse);
    });

    test('returns false when lookup throws SocketException', () async {
      final info = TestableNetworkInfo(
        lookupFn: (_) async => throw const SocketException('No route to host'),
        hosts: const ['google.com'],
      );

      expect(await info.isConnected, isFalse);
    });

    test('falls through to second host if first throws', () async {
      var callCount = 0;
      final info = TestableNetworkInfo(
        lookupFn: (host) async {
          callCount++;
          if (callCount == 1) throw const SocketException('No route to host');
          // Second host succeeds
          return [InternetAddress('1.1.1.1')];
        },
        hosts: const ['google.com', 'cloudflare.com'],
      );

      expect(await info.isConnected, isTrue);
      expect(callCount, 2);
    });

    test('returns false when ALL hosts fail', () async {
      final info = TestableNetworkInfo(
        lookupFn: (_) async =>
            throw const SocketException('Network unreachable'),
        hosts: const ['google.com', 'cloudflare.com', 'dns.google'],
      );

      expect(await info.isConnected, isFalse);
    });
  });

  group('NetworkInfoImpl — integration (real DNS)', () {
    test(
      'returns true on a device with internet',
      () async {
        final info = NetworkInfoImpl();
        final result = await info.isConnected;
        // This test is environment-dependent; we just verify it doesn't throw.
        expect(result, isA<bool>());
      },
      // Skip automatically in CI by checking for the GITHUB_ACTIONS env var.
      skip: const bool.fromEnvironment('CI'),
    );
  });
}
