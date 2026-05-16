import 'dart:io';
import '../../../core/supabase/auth_local_data_source.dart';
import '../../../core/supabase/auth_remote_data_source.dart';
import '../../profile/model/profile_model.dart';
import '../model/user_model.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    AuthRemoteDataSource? dataSource,
    AuthLocalDataSource? localDataSource,
  })  : _ds = dataSource ?? AuthRemoteDataSource(),
        _local = localDataSource ?? AuthLocalDataSource.instance;

  final AuthRemoteDataSource _ds;
  final AuthLocalDataSource _local;

  @override
  UserModel? get currentUser {
    final user = _ds.currentUser;
    return user != null ? UserModel.fromSupabaseUser(user) : null;
  }

  @override
  Future<UserModel?> restoreSession() => _ds.restoreSession();

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? phone,
  }) =>
      _ds.signUp(email: email, password: password, phone: phone);

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) =>
      _ds.signIn(email: email, password: password);

  @override
  Future<void> signOut() => _ds.signOut();

  @override
  Future<void> sendPasswordReset(String email) => _ds.resetPasswordForEmail(
        email,
        redirectTo: 'io.newswave://reset-password', // ← register in app scheme
      );

  @override
  Future<void> updatePassword(String newPassword) =>
      _ds.updatePassword(newPassword);

  @override
  Future<void> updateEmail(String newEmail) => _ds.updateEmail(newEmail);

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      //  Network first
      return _ds.getProfile(userId);
    } catch (_) {
      //  Network failed → serve from cache
      return _local.getCachedProfile();
    }
  }

  @override
  Future<ProfileModel> upsertProfile(ProfileModel profile) async {
    try {
      // Network first (also writes through to cache inside remote ds)

      return _ds.upsertProfile(profile);
    } catch (_) {
      //  Network failed → persist locally and return the passed profile so
      //  the UI stays consistent.
      await _local.cacheProfile(profile);
      return profile;
    }
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) =>
      _ds.uploadAvatar(userId: userId, imageFile: imageFile);
}
