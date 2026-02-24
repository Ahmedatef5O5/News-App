import 'package:flutter/material.dart';
import '../../../core/utilities/theme/app_colors.dart';

class CustomContainerIcon extends StatelessWidget {
  const CustomContainerIcon({
    super.key,
    required this.widgetIcon,
    this.onTap,
    this.height,
    this.width,
  });
  final Widget widgetIcon;
  final VoidCallback? onTap;
  final double? height, width;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 42,
      width: width ?? 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey2Color,
      ),
      child: IconButton(onPressed: () {}, icon: widgetIcon),
    );
  }
}
