import 'package:application/widgets/backgorund/SoftBlurCirclesPainter.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class BlurredBackground extends StatelessWidget {
  final Widget child;

  const BlurredBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: SoftBlurCirclesPainter(
            color: AppColors.primary,
            circleCount: 40,
            seed: 123, // شكل ثابت
          ),
        ),
        child,
      ],
    );
  }
}
