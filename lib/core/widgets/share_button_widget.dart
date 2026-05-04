import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/article_model.dart';
import '../theme/app_colors.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    required this.article,
  });

  final Article article;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final text = '${article.title}\n\n${article.url ?? ""}';
        await SharePlus.instance.share(
          ShareParams(
            text: text,
            subject: article.title,
          ),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: const Text(
                  'Link copied to clipboard',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(milliseconds: 1800),
              ),
            );
        }
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: const Icon(
          Icons.share_outlined,
          size: 16,
          color: AppColors.ink300,
        ),
      ),
    );
  }
}
