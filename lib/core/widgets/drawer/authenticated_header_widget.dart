import 'package:flutter/material.dart';
import 'package:news_app/core/widgets/drawer/initials_avatar.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';

class AuthenticatedHeader extends StatelessWidget {
  const AuthenticatedHeader({
    super.key,
    required this.profile,
    required this.email,
    required this.tt,
  });

  final dynamic profile;
  final String email;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(AppRoutes.profileSettingsRoute);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: ClipOval(
                child: profile?.avatarUrl != null
                    ? Image.network(
                        profile!.avatarUrl as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            InitialsAvatar(initials: profile?.initials ?? 'N'),
                      )
                    : InitialsAvatar(initials: profile?.initials ?? 'N'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.displayName ?? 'NewsWave User',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: tt.bodySmall?.copyWith(color: AppColors.ink300),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.ink300, size: 20),
          ],
        ),
      ),
    );
  }
}
