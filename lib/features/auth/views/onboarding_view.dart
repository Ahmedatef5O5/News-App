import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../../profile/model/profile_model.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/glass_auth_scaffold.dart';
import '../widgets/step_indicator_widget.dart';
import '../widgets/step_one_names.dart';
import '../widgets/step_three_categories.dart';
import '../widgets/step_two_hobby.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pageCtrl = PageController();
  int _page = 0;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  String? _selectedCountry;
  String? _selectedHobby;
  final Set<String> _selectedCategories = {};

  final _page0Key = GlobalKey<FormState>();

  @override
  void dispose() {
    _pageCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == 0 && !_page0Key.currentState!.validate()) return;
    if (_page < 2) {
      _pageCtrl.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _submit();
    }
  }

  void _skip() {
    final cubit = context.read<AuthCubit>();
    final userId = cubit.currentUser?.id;
    if (userId == null) return;
    cubit.saveProfile(
      ProfileModel(id: userId, isOnboarded: true),
    );
  }

  void _submit() {
    final cubit = context.read<AuthCubit>();
    final userId = cubit.currentUser?.id;
    if (userId == null) return;

    cubit.saveProfile(
      ProfileModel(
        id: userId,
        firstName: _firstNameCtrl.text.trim().isEmpty
            ? null
            : _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim().isEmpty
            ? null
            : _lastNameCtrl.text.trim(),
        country: _selectedCountry,
        hobby: _selectedHobby,
        preferredCategories: _selectedCategories.toList(),
        isOnboarded: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<AuthCubit, AuthUserState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && !state.needsOnboarding) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.homeRoute,
            (r) => false,
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
      child: GlassAuthScaffold(
        child: Column(
          children: [
            const SizedBox(height: 20),
            StepIndicator(currentStep: _page, totalSteps: 3),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  l10n.onboardingSkip,
                  style: const TextStyle(
                    color: AppColors.ink300,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  StepOneNames(
                    formKey: _page0Key,
                    firstNameCtrl: _firstNameCtrl,
                    lastNameCtrl: _lastNameCtrl,
                    selectedCountry: _selectedCountry,
                    onCountryChanged: (c) =>
                        setState(() => _selectedCountry = c),
                  ),
                  StepTwoHobby(
                    selected: _selectedHobby,
                    onSelected: (h) => setState(() => _selectedHobby = h),
                  ),
                  StepThreeCategories(
                    selected: _selectedCategories,
                    onToggle: (cat) => setState(() {
                      if (_selectedCategories.contains(cat)) {
                        _selectedCategories.remove(cat);
                      } else {
                        _selectedCategories.add(cat);
                      }
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: BlocBuilder<AuthCubit, AuthUserState>(
                builder: (context, state) => AuthPrimaryButton(
                  label: _page == 2
                      ? l10n.onboardingGetStarted
                      : l10n.onboardingContinue,
                  isLoading: state is AuthLoading,
                  onPressed: _next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
