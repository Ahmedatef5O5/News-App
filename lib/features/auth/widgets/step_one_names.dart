import 'package:flutter/material.dart';
import 'package:news_app/features/auth/widgets/auth_text_field.dart';
import 'package:news_app/features/auth/widgets/glass_card_widget.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/model/profile_model.dart';

class StepOneNames extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final String? selectedCountry;
  final void Function(String?) onCountryChanged;

  const StepOneNames({
    super.key,
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              '👋 Tell us about yourself',
              style:
                  txtTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'This helps us personalise your news feed.',
              style: txtTheme.bodyMedium?.copyWith(color: AppColors.ink300),
            ),
            const SizedBox(height: 28),
            GlassCard(
              child: Column(
                children: [
                  AuthTextField(
                    controller: firstNameCtrl,
                    label: l10n.fieldFirstName,
                    icon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v == null || v.isEmpty
                        ? '${l10n.fieldFirstName} is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: lastNameCtrl,
                    label: l10n.fieldLastName,
                    icon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.done,
                    validator: (v) => v == null || v.isEmpty
                        ? '${l10n.fieldLastName} is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCountry,
                    isExpanded: true,
                    onChanged: onCountryChanged,
                    decoration: InputDecoration(
                      labelText: l10n.fieldCountry,
                      prefixIcon: const Icon(
                        Icons.public_rounded,
                        size: 20,
                        color: AppColors.ink300,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.7),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
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
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                    hint: Text(l10n.onboardingSelectCountryHint),
                    items: CountriesList.all
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  )),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
