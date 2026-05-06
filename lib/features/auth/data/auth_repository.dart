import 'dart:io';
import '../../profile/model/profile_model.dart';
import '../model/user_model.dart';

abstract class AuthRepository {
  UserModel? get currentUser;

  /// Restores a persisted session on cold start.
  Future<UserModel?> restoreSession();

  Future<UserModel> signUp({
    required String email,
    required String password,
    String? phone,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordReset(String email);

  Future<void> updatePassword(String newPassword);

  Future<void> updateEmail(String newEmail);

  Future<ProfileModel?> getProfile(String userId);

  Future<ProfileModel> upsertProfile(ProfileModel profile);

  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  });
}
