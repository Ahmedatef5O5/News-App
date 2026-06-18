import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/network/network_info.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(
    this._networkInfo, {
    Connectivity? connectivity,
  })  : _connectivity = connectivity ?? Connectivity(),
        super(true) {
    _init();
  }

  final NetworkInfo _networkInfo;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Timer? _debounce;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _debounceDelay = Duration(milliseconds: 1500);

  Future<void> _init() async {
    final initial = await _networkInfo.isConnected;
    if (!isClosed) emit(initial);

    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    final hasInterface = results.any((r) => r != ConnectivityResult.none);

    if (!hasInterface) {
      _debounce?.cancel();
      _debounce = null;
      _retryCount = 0;
      if (!isClosed) emit(false);
      return;
    }

    _debounce?.cancel();
    _retryCount = 0;
    _debounce = Timer(_debounceDelay, _checkWithRetry);
  }

  Future<void> _checkWithRetry() async {
    if (isClosed) return;

    final connected = await _networkInfo.isConnected;

    if (connected) {
      if (!isClosed) emit(true);
      _retryCount = 0;
      return;
    }

    _retryCount++;
    if (_retryCount < _maxRetries) {
      final delay = Duration(seconds: 2 * _retryCount);
      _debounce = Timer(delay, _checkWithRetry);
    } else {
      if (!isClosed) emit(false);
      _retryCount = 0;
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _subscription?.cancel();
    return super.close();
  }
}
