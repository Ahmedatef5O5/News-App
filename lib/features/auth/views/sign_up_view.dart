import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/glass_auth_scaffold.dart';
import '../widgets/glass_card_widget.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the Terms & Privacy Policy'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    context.read<AuthCubit>().signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return BlocListener<AuthCubit, AuthUserState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Always go to onboarding after new sign-up
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.onboardingRoute,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // ── Back + title ──────────────────────────────────────────────
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.authCreateAccount,
                    style: txtTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join ${AppConstants.appName}',
                        style: txtTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your personalised news experience awaits',
                        style: txtTheme.bodySmall
                            ?.copyWith(color: AppColors.ink300),
                      ),
                      const SizedBox(height: 24),
                      AuthTextField(
                        controller: _emailCtrl,
                        label: l10n.authFieldEmail,
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.validationEmailRequired;
                          }
                          if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                              .hasMatch(v.trim())) {
                            return l10n.validationEmailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _passCtrl,
                        label: l10n.authFieldPassword,
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.length < 6) {
                            return l10n.validationPasswordTooShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _confirmPassCtrl,
                        label: l10n.authFieldConfirmPassword,
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v != _passCtrl.text) {
                            return l10n.validationPasswordsNoMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // ── Phone (Optional) ─────────────────────────────────
                      AuthTextField(
                        controller: _phoneCtrl,
                        label: 'Phone number (optional)',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        hint: '+1 234 567 8900',
                        // No validator – field is optional
                      ),
                      const SizedBox(height: 20),
                      // ── Terms checkbox ────────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (v) =>
                                setState(() => _agreeToTerms = v ?? false),
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: RichText(
                                text: TextSpan(
                                  style: txtTheme.bodySmall?.copyWith(
                                    color: AppColors.ink500,
                                  ),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    const TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    const TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      BlocBuilder<AuthCubit, AuthUserState>(
                        builder: (context, state) => AuthPrimaryButton(
                          label: l10n.authCreateAccount,
                          isLoading: state is AuthLoading,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.authAlreadyHaveAccount,
                    style:
                        txtTheme.bodyMedium?.copyWith(color: AppColors.ink300),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Sign In',
                      style: txtTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
