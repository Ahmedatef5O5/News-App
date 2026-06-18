import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/widgets/app_snack_bar.dart';
import 'package:news_app/features/auth/cubit/auth_error_x.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/glass_auth_scaffold.dart';
import '../widgets/glass_card_widget.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signIn(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return BlocListener<AuthCubit, AuthUserState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.needsOnboarding) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.onboardingRoute,
              (r) => false,
            );
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.homeRoute,
              (r) => false,
            );
          }
        }
        if (state is AuthError) {
          AppSnackBar.show(context,
              state.code.localizedMessage(context, extra: state.extra));
        }
      },
      child: GlassAuthScaffold(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _LogoBadge(),
              const SizedBox(height: 32),
              GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.authWelcomeBack,
                        style: txtTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.signInToApp,
                        style: txtTheme.bodyMedium?.copyWith(
                          color: AppColors.ink300,
                        ),
                      ),
                      const SizedBox(height: 28),
                      AuthTextField(
                        controller: _emailCtrl,
                        label: l10n.authFieldEmail,
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        focusNode: _emailFocus,
                        onFieldSubmitted: (_) => _passFocus.requestFocus(),
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
                        textInputAction: TextInputAction.done,
                        focusNode: _passFocus,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.validationPasswordRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.forgotPasswordRoute),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 36),
                          ),
                          child: Text(
                            l10n.authForgotPassword,
                            style: txtTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<AuthCubit, AuthUserState>(
                        builder: (context, state) => AuthPrimaryButton(
                          label: l10n.authSignIn,
                          isLoading: state is AuthLoading,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _OrDivider(),
              const SizedBox(height: 20),
              _GuestButton(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.authNoAccount,
                    style:
                        txtTheme.bodyMedium?.copyWith(color: AppColors.ink300),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.signUpRoute),
                    child: Text(
                      l10n.authCreateAccount,
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

class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/images/icons/icon_1024x1024.png',
              width: 66,
              height: 66,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            context.l10n.authOr,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.ink300,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _GuestButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<AuthCubit>().continueAsGuest();
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.homeRoute,
            (r) => false,
          );
        },
        icon: const Icon(Icons.person_outline_rounded),
        label: Text(context.l10n.browsingAsGuest),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink500,
          side: const BorderSide(color: AppColors.ink100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
