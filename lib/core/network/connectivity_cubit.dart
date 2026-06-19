import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/network/network_info.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(
    this._networkInfo, {
    Duration pollInterval = const Duration(seconds: 10),
  })  : _pollInterval = pollInterval,
        super(false) {
    _init();
  }

  final NetworkInfo _networkInfo;
  final Duration _pollInterval;
  Timer? _timer;

  Future<void> _init() async {
    final initial = await _networkInfo.isConnected;
    if (!isClosed) emit(initial);

    _timer = Timer.periodic(_pollInterval, (_) async {
      final connected = await _networkInfo.isConnected;
      if (!isClosed && connected != state) emit(connected);
    });
  }

  Future<void> recheck() async {
    final connected = await _networkInfo.isConnected;
    if (!isClosed && connected != state) emit(connected);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
