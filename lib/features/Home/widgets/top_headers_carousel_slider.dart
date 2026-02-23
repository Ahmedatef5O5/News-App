import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:gap/gap.dart';

class CustomCarouselSlider extends StatefulWidget {
  final List<Widget> items;
  final double height;

  const CustomCarouselSlider({
    super.key,
    required this.items,
    this.height = 180,
  });

  @override
  State<CustomCarouselSlider> createState() => _CustomCarouselSliderState();
}

class _CustomCarouselSliderState extends State<CustomCarouselSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        FlutterCarousel.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index, pageViewIndex) {
            return widget.items[index];
          },
          options: FlutterCarouselOptions(
            height: widget.height,
            viewportFraction: 0.85,
            autoPlay: true,
            enlargeCenterPage: true,
            showIndicator: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        const Gap(8),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (index) {
            final isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
              ),
            );
          }),
        ),
      ],
    );
  }
}
