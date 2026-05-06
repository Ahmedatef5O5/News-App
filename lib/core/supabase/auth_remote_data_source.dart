import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/model/user_model.dart';
import '../../features/profile/model/profile_model.dart';
import 'auth_exception.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<UserModel> signUp({
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: phone != null && phone.isNotEmpty ? {'phone': phone} : null,
      );
      final user = response.user;
      if (user == null) {
        throw const UnknownAuthException(
          'Sign-up succeeded but no user was returned.',
        );
      }
      return UserModel.fromSupabaseUser(user);
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) throw const InvalidCredentialsException();
      return UserModel.fromSupabaseUser(user);
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut(scope: SignOutScope.global);
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  // ─── Password Reset ───────────────────────────────────────────────────────

  /// Sends a reset-password email via Supabase Auth (you can customise
  /// the template in the Supabase dashboard or hook Resend via SMTP).
  ///
  /// [redirectTo] should be a deep-link URL registered in your app
  /// (e.g. `io.newswave://reset-password`).
  Future<void> resetPasswordForEmail(
    String email, {
    String? redirectTo,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: redirectTo,
      );
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<UserModel?> restoreSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return null;
      return UserModel.fromSupabaseUser(session.user);
    } catch (_) {
      return null;
    }
  }

  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return ProfileModel.fromMap(data);
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  /// Upserts (insert or update) the `profiles` row.
  Future<ProfileModel> upsertProfile(ProfileModel profile) async {
    try {
      final data = await _client
          .from('profiles')
          .upsert(profile.toMap())
          .select()
          .single();
      return ProfileModel.fromMap(data);
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ext = imageFile.path.split('.').last;
      final path = '$userId/avatar.$ext';

      await _client.storage.from('avatars').upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final url = _client.storage.from('avatars').getPublicUrl(path);
      return url;
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(email: newEmail.trim()),
      );
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }
}
