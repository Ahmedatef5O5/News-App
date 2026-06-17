import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthListenerCubit extends Cubit<void> {
  late final StreamSubscription<AuthState> _sub;

  AuthListenerCubit() : super(null) {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen(_onAuth);
  }

  void _onAuth(AuthState data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.upadatePasswordRoute, (route) => false);
    }
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
