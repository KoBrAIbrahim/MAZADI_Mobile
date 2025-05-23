import 'package:flutter/material.dart';
import 'dart:math';

class SoftBlurCirclesPainter extends CustomPainter {
  final Color color;
  final int circleCount;
  final int seed;

  SoftBlurCirclesPainter({
    required this.color,
    this.circleCount = 35,
    this.seed = 123,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = Random(seed);

    for (int i = 0; i < circleCount; i++) {
      final double radius = random.nextDouble() * (size.width * 0.2) + size.width * 0.05;

      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height; 

      final double opacity = 0.02 + random.nextDouble() * 0.07;
      paint.color = color.withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
