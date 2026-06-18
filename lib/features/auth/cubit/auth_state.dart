import 'package:equatable/equatable.dart';
import '../../../core/supabase/auth_exception.dart';
import '../../profile/model/profile_model.dart';
import '../model/user_model.dart';

sealed class AuthUserState extends Equatable {
  const AuthUserState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthUserState {
  const AuthInitial();
}

final class AuthLoading extends AuthUserState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthUserState {
  const AuthAuthenticated({
    required this.user,
    required this.profile,
  });

  final UserModel user;
  final ProfileModel profile;

  bool get needsOnboarding => !profile.isOnboarded;

  @override
  List<Object?> get props => [user, profile];
}

final class AuthGuest extends AuthUserState {
  const AuthGuest();
}

final class AuthUnauthenticated extends AuthUserState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthUserState {
  const AuthError(this.code, {this.extra});

  final AuthErrorCode code;
  final String? extra;

  @override
  List<Object?> get props => [code, extra];
}

final class AuthPasswordResetSent extends AuthUserState {
  const AuthPasswordResetSent(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}
