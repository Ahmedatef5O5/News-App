import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/theme/model/theme_model.dart';
import 'package:news_app/core/theme/theme_options.dart';

class ThemePickerDialog {
  ThemePickerDialog._();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ThemeCubit>(),
        child: const _ThemePickerContent(),
      ),
    );
  }
}

class _ThemePickerContent extends StatefulWidget {
  const _ThemePickerContent();

  @override
  State<_ThemePickerContent> createState() => _ThemePickerContentState();
}

class _ThemePickerContentState extends State<_ThemePickerContent> {
  ThemeMode _selected = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.ink100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '🎨 Choose Your Theme',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Pick how NewsWave looks for you. You can change this any time.',
              style: tt.bodyMedium?.copyWith(color: AppColors.ink300),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ThemeOption(
                  icon: Icons.light_mode_rounded,
                  label: 'Light',
                  mode: ThemeMode.light,
                  selected: _selected,
                  onTap: () => setState(() => _selected = ThemeMode.light),
                ),
                const SizedBox(width: 12),
                ThemeOption(
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark',
                  mode: ThemeMode.dark,
                  selected: _selected,
                  onTap: () => setState(() => _selected = ThemeMode.dark),
                ),
                const SizedBox(width: 12),
                ThemeOption(
                  icon: Icons.brightness_auto_rounded,
                  label: 'System',
                  mode: ThemeMode.system,
                  selected: _selected,
                  onTap: () => setState(() => _selected = ThemeMode.system),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () async {
                  await context.read<ThemeCubit>().setTheme(_selected);
                  if (mounted) Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontFamily: 'Poppins',
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
