import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'network_info.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._networkInfo) : super(true) {
    _checkNow();
    _startMonitoring();
  }

  final NetworkInfo _networkInfo;
  Timer? _timer;

  Future<void> _checkNow() async {
    final connected = await _networkInfo.isConnected;
    if (isClosed) return;
    if (connected != state) emit(connected);
  }

  void _startMonitoring() {
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) async {
        final connected = await _networkInfo.isConnected;
        if (connected != state) {
          emit(connected);
        }
      },
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
