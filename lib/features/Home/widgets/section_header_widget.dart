import 'package:flutter/material.dart';
import 'package:news_app/l10n/app_localizations_x.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String label;
  final Color accentColor;
  final VoidCallback? onViewAll;
  final Widget? trailing;
  final Key? forYouKey;

  const SectionHeaderWidget({
    super.key,
    this.forYouKey,
    required this.label,
    required this.accentColor,
    this.onViewAll,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
      child: Row(
        key: forYouKey,
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: txtTheme.headlineMedium?.copyWith(fontSize: 18),
          ),
          const Spacer(),
          if (trailing != null)
            trailing!
          else if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Text(context.l10n.viewAll),
            ),
        ],
      ),
    );
  }
}
