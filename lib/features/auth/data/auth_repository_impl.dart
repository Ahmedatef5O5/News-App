import 'dart:io';
import '../../../core/supabase/auth_remote_data_source.dart';
import '../../profile/model/profile_model.dart';
import '../model/user_model.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthRemoteDataSource? dataSource})
      : _ds = dataSource ?? AuthRemoteDataSource();

  final AuthRemoteDataSource _ds;

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
  Future<ProfileModel?> getProfile(String userId) => _ds.getProfile(userId);

  @override
  Future<ProfileModel> upsertProfile(ProfileModel profile) =>
      _ds.upsertProfile(profile);

  @override
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) =>
      _ds.uploadAvatar(userId: userId, imageFile: imageFile);
}
