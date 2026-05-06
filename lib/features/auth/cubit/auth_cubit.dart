import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/features/auth/cubit/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/model/profile_model.dart';
import '../data/auth_repository.dart';
import '../data/auth_repository_impl.dart';
import '../model/user_model.dart';

class AuthCubit extends Cubit<AuthUserState> {
  AuthCubit({AuthRepository? repository})
      : _repo = repository ?? AuthRepositoryImpl(),
        super(const AuthInitial());

  final AuthRepository _repo;

  Future<void> init() async {
    emit(const AuthLoading());
    try {
      final user = await _repo.restoreSession();
      if (user == null) {
        emit(const AuthUnauthenticated());
        return;
      }
      await _loadProfileAndEmit(user);
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  // ─── Guest Mode ───────────────────────────────────────────────────────────

  /// User chose "Continue as Guest".
  void continueAsGuest() => emit(const AuthGuest());

  /// Exits guest mode back to unauthenticated (shows sign-in).
  void exitGuestMode() => emit(const AuthUnauthenticated());

  // ─── Sign Up ──────────────────────────────────────────────────────────────

  Future<void> signUp({
    required String email,
    required String password,
    String? phone,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.signUp(
        email: email,
        password: password,
        phone: phone,
      );
      // Profile row is created by the Supabase trigger; fetch it.
      await _loadProfileAndEmit(user);
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ─── Sign In ──────────────────────────────────────────────────────────────

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.signIn(email: email, password: password);
      await _loadProfileAndEmit(user);
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await _repo.signOut();
      emit(const AuthUnauthenticated());
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    }
  }

  // ─── Password Reset ───────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    emit(const AuthLoading());
    try {
      await _repo.sendPasswordReset(email);
      emit(AuthPasswordResetSent(email));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    emit(const AuthLoading());
    try {
      await _repo.updatePassword(newPassword);
      // Re-emit current authenticated state to reset the UI.
      final current = state;
      if (current is AuthAuthenticated) {
        emit(AuthAuthenticated(user: current.user, profile: current.profile));
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    }
  }

  // ─── Profile ──────────────────────────────────────────────────────────────

  /// Saves onboarding data and marks the profile as complete.
  Future<void> saveProfile(ProfileModel profile) async {
    final current = state;
    if (current is! AuthAuthenticated) return;
    emit(const AuthLoading());
    try {
      final saved = await _repo.upsertProfile(
        profile.copyWith(isOnboarded: true),
      );
      emit(AuthAuthenticated(user: current.user, profile: saved));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    }
  }

  /// Uploads a new avatar and refreshes the profile.
  Future<void> uploadAvatar(File imageFile) async {
    final current = state;
    if (current is! AuthAuthenticated) return;
    emit(const AuthLoading());
    try {
      final url = await _repo.uploadAvatar(
        userId: current.user.id,
        imageFile: imageFile,
      );
      final updatedProfile =
          await _repo.upsertProfile(current.profile.copyWith(avatarUrl: url));
      emit(AuthAuthenticated(user: current.user, profile: updatedProfile));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    }
  }

  /// Updates a profile field (name, hobby, country, categories, etc.)
  /// without re-fetching everything from the network.
  Future<void> updateProfile(ProfileModel updatedProfile) async {
    final current = state;
    if (current is! AuthAuthenticated) return;
    emit(const AuthLoading());
    try {
      final saved = await _repo.upsertProfile(updatedProfile);
      emit(AuthAuthenticated(user: current.user, profile: saved));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    }
  }

  Future<void> _loadProfileAndEmit(UserModel user) async {
    final profile = await _repo.getProfile(user.id) ??
        ProfileModel(id: user.id); // fallback: empty profile
    emit(AuthAuthenticated(user: user, profile: profile));
  }

  // ─── Convenience getters ──────────────────────────────────────────────────

  bool get isAuthenticated => state is AuthAuthenticated;
  bool get isGuest => state is AuthGuest;
  bool get isLoggedIn => isAuthenticated || isGuest;

  UserModel? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  ProfileModel? get currentProfile =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).profile : null;
}
