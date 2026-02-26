import 'dart:ui';
import 'package:flutter/material.dart';

class CustomGlassContainer extends StatelessWidget {
  const CustomGlassContainer({
    super.key,
    required this.child,
    this.blur = 12,
    this.padding,
    required this.onTap,
    this.width,
    this.height,
  });
  final Widget child;
  final double blur;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 45,
      width: width ?? 45,
      child: ClipOval(
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    // height: height ?? 46,
                    // width: width ?? 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                      // border: Border.all(
                      //   color: Colors.black12.withOpacity(0.2),
                      //   width: 1.5,
                      // ),
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
