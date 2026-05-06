import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class Tagline extends StatelessWidget {
  const Tagline({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Stay ahead of the story',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF8E97B0),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}
