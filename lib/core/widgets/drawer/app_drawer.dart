import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/locale/locale_model.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/widgets/drawer/authenticated_header_widget.dart';
import 'package:news_app/core/widgets/drawer/category_item.dart';
import 'package:news_app/core/widgets/drawer/drawer_item.dart';
import 'package:news_app/core/widgets/drawer/guest_header_widget.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../../../features/auth/cubit/auth_cubit.dart';
import '../../../features/auth/cubit/auth_state.dart';
import '../../theme/model/theme_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.82,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<AuthCubit, AuthUserState>(
                      builder: (context, state) {
                        if (state is AuthAuthenticated) {
                          return AuthenticatedHeader(
                              profile: state.profile,
                              email: state.user.email,
                              txtTheme: txtTheme);
                        }
                        return GuestHeader(txtTheme: txtTheme);
                      },
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.drawerSectionMenu,
                        style: txtTheme.labelSmall?.copyWith(
                          letterSpacing: 1.5,
                          color: AppColors.ink300,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DrawerItem(
                      icon: Icons.home_rounded,
                      label: l10n.navHome,
                      isActive: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    DrawerItem(
                      icon: Icons.bookmark_rounded,
                      label: l10n.navSavedArticles,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushNamed(AppRoutes.favoriteRoute);
                      },
                    ),
                    DrawerItem(
                      icon: Icons.search_rounded,
                      label: l10n.navSearch,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(AppRoutes.searchRoute);
                      },
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.drawerSectionCategories,
                        style: txtTheme.labelSmall?.copyWith(
                          letterSpacing: 1.5,
                          color: AppColors.ink300,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...NewsCategory.values
                        .where((c) => c != NewsCategory.general)
                        .map((cat) => CategoryItem(category: cat)),
                    const Spacer(),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: BlocBuilder<ThemeCubit, ThemeMode>(
                        builder: (context, mode) {
                          final isDark = mode == ThemeMode.dark;
                          return Row(
                            children: [
                              Icon(
                                isDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                size: 20,
                                color:
                                    isDark ? Colors.amber : AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isDark ? l10n.darkMode : l10n.lightMode,
                                style: txtTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Switch.adaptive(
                                value: isDark,
                                onChanged: (_) =>
                                    context.read<ThemeCubit>().toggle(),
                                activeColor: AppColors.primary,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: BlocBuilder<LocaleCubit, Locale>(
                          builder: (context, locale) {
                            final isArabic = locale.languageCode == 'ar';
                            return InkWell(
                              onTap: () => LanguagePickerDialog.show(context),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(children: [
                                  const Icon(
                                    Icons.translate_rounded,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    isArabic
                                        ? l10n.languageArabic
                                        : l10n.languageEnglish,
                                    style: txtTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: AppColors.ink300,
                                  ),
                                ]),
                              ),
                            );
                          },
                        )),
                    BlocBuilder<AuthCubit, AuthUserState>(
                      builder: (context, state) {
                        if (state is AuthAuthenticated) {
                          return DrawerItem(
                            icon: Icons.logout_rounded,
                            label: l10n.signOut,
                            iconColor: AppColors.error,
                            labelColor: AppColors.error,
                            onTap: () => _confirmSignOut(context),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 12),
                      child: Text(
                        '${context.l10n.appName} ${context.l10n.appVersion}',
                        style: txtTheme.labelSmall
                            ?.copyWith(color: AppColors.ink300),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.signInRoute,
          (r) => false,
        );
      }
    }
  }
}
