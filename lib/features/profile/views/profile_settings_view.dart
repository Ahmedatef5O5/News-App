import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app/core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_app_bar_icon.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../model/profile_model.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/section_title.dart';

class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _newPassCtrl;
  String? _selectedCountry;
  String? _selectedHobby;
  late Set<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthCubit>().currentProfile;
    _firstNameCtrl = TextEditingController(text: profile?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: profile?.lastName ?? '');
    _newPassCtrl = TextEditingController();
    _selectedCountry = profile?.country;
    _selectedHobby = profile?.hobby;
    _selectedCategories = Set.from(profile?.preferredCategories ?? []);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !mounted) return;
    context.read<AuthCubit>().uploadAvatar(File(picked.path));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AuthCubit>();
    final userId = cubit.currentUser?.id;
    if (userId == null) return;

    cubit.updateProfile(
      ProfileModel(
        id: userId,
        firstName: _firstNameCtrl.text.trim().isEmpty
            ? null
            : _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim().isEmpty
            ? null
            : _lastNameCtrl.text.trim(),
        avatarUrl: cubit.currentProfile?.avatarUrl,
        country: _selectedCountry,
        hobby: _selectedHobby,
        preferredCategories: _selectedCategories.toList(),
        isOnboarded: true,
      ),
    );

    // Update password if filled
    if (_newPassCtrl.text.isNotEmpty) {
      cubit.updatePassword(_newPassCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return BlocListener<AuthCubit, AuthUserState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leadingWidth: 42,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CustomAppBarIcon(
              icon: CupertinoIcons.chevron_back,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          title: const Text('Profile Settings'),
          actions: [
            BlocBuilder<AuthCubit, AuthUserState>(
              builder: (context, state) => TextButton(
                onPressed: state is AuthLoading ? null : _save,
                child: state is AuthLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<AuthCubit, AuthUserState>(
          builder: (context, state) {
            final profile = state is AuthAuthenticated ? state.profile : null;
            final user = state is AuthAuthenticated ? state.user : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickAvatar,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.2),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: profile?.avatarUrl != null
                                    ? Image.network(
                                        profile!.avatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            InitialsAvatar(
                                          initials: profile.initials,
                                          size: 100,
                                        ),
                                      )
                                    : InitialsAvatar(
                                        initials: profile?.initials ?? 'N',
                                        size: 100,
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickAvatar,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (user != null)
                      Center(
                        child: Text(
                          user.email,
                          style: tt.bodySmall?.copyWith(
                            color: AppColors.ink300,
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                    SectionTitle(title: 'Personal Information'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: _firstNameCtrl,
                      label: 'First name',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: _lastNameCtrl,
                      label: 'Last name',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      isExpanded: true,
                      onChanged: (c) => setState(() => _selectedCountry = c),
                      decoration: _dropdownDecoration(
                          context, 'Country', Icons.public_rounded),
                      hint: const Text('Select country'),
                      items: CountriesList.all
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins', fontSize: 13)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                    SectionTitle(title: 'Security'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: _newPassCtrl,
                      label: 'New password (leave blank to keep current)',
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    SectionTitle(title: 'Interests'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedHobby,
                      isExpanded: true,
                      onChanged: (h) => setState(() => _selectedHobby = h),
                      decoration: _dropdownDecoration(
                          context, 'Hobby', Icons.favorite_outline_rounded),
                      hint: const Text('Select hobby'),
                      items: HobbyList.suggestions
                          .map((h) => DropdownMenuItem(
                                value: h,
                                child: Text(h,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins', fontSize: 13)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    SectionTitle(title: 'Preferred News Categories'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: NewsCategory.values.map((cat) {
                        final isSelected =
                            _selectedCategories.contains(cat.value);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (isSelected) {
                              _selectedCategories.remove(cat.value);
                            } else {
                              _selectedCategories.add(cat.value);
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.ink100,
                              ),
                            ),
                            child: Text(
                              cat.label,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.ink700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(
      BuildContext context, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: AppColors.ink300),
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.ink100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.ink100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
