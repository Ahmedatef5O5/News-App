import 'package:hive/hive.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/features/profile/model/profile_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource._();
  static final AuthLocalDataSource instance = AuthLocalDataSource._();

  Box<ProfileModel>? _box;

  // ─── Box lifecycle ────────────────────────────────────────────────────────

  Future<Box<ProfileModel>> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<ProfileModel>(AppConstants.profileBox);
    return _box!;
  }

  /// Call this every time a profile is successfully fetched from or written to
  /// Supabase so the cache is always fresh.
  Future<void> cacheProfile(ProfileModel profile) async {
    final box = await _getBox();
    await box.put(AppConstants.cachedProfileKey, profile);
  }

  /// Returns the last cached profile, or `null` if nothing is cached.
  Future<ProfileModel?> getCachedProfile() async {
    final box = await _getBox();
    return box.get(AppConstants.cachedProfileKey);
  }

  /// Removes the cached profile (called on sign-out).
  Future<void> clearProfile() async {
    final box = await _getBox();
    await box.delete(AppConstants.cachedProfileKey);
  }
}
