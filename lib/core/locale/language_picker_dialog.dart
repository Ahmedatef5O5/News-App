import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/locale/language_option.dart';
import 'package:news_app/core/locale/locale_cubit.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../theme/app_colors.dart';

class LanguagePickerDialog {
  LanguagePickerDialog._();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (_) => BlocProvider.value(
              value: context.read<LocaleCubit>(),
              child: const _LanguagePickerContent(),
            ));
  }
}

class _LanguagePickerContent extends StatefulWidget {
  const _LanguagePickerContent();

  @override
  State<_LanguagePickerContent> createState() => _LanguagePickerContentState();
}

class _LanguagePickerContentState extends State<_LanguagePickerContent> {
  late Locale _selected;

  @override
  void initState() {
    super.initState();
    _selected = context.read<LocaleCubit>().state;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        // Mirrors ThemePickerDialog padding exactly.
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ───────────────────────────────────────────────
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.ink100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              '🌐 ${l10n.languageSectionTitle}',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),

            // ── Subtitle ──────────────────────────────────────────────────
            Text(
              l10n.languagePickerSubtitle,
              style: tt.bodyMedium?.copyWith(color: AppColors.ink300),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                LanguageOption(
                  icon: Icons.language_rounded,
                  // Always display the English label in English, even when
                  // Arabic is active — so the user can always find it.
                  label: l10n.languageEnglish,
                  locale: const Locale('en'),
                  selected: _selected,
                  onTap: () => setState(() => _selected = const Locale('en')),
                ),
                const SizedBox(width: 12),
                LanguageOption(
                  icon: Icons.translate_rounded,
                  // Always display the Arabic label in its own script.
                  label: l10n.languageArabic,
                  locale: const Locale('ar'),
                  selected: _selected,
                  onTap: () => setState(() => _selected = const Locale('ar')),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () async {
                  await context.read<LocaleCubit>().setLocale(_selected);
                  if (mounted) Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.confirm,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
