import 'package:flutter/material.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/model/profile_model.dart';

class StepTwoHobby extends StatelessWidget {
  final String? selected;
  final void Function(String) onSelected;

  const StepTwoHobby(
      {super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            '🎯 What are you into?',
            style:
                txtTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.onboardingHobbySubtitle,
            style: txtTheme.bodyMedium?.copyWith(color: AppColors.ink300),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: HobbyList.suggestions.map((h) {
              final isSelected = h == selected;
              return GestureDetector(
                onTap: () => onSelected(h),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primary : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.ink100,
                    ),
                  ),
                  child: Text(
                    h,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.ink700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
