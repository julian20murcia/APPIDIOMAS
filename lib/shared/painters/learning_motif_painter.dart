import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class LearningMotifPainter extends CustomPainter {
  final double t;

  const LearningMotifPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Brand.white.withOpacity(.07);

    for (int i = 0; i < 7; i++) {
      final y = size.height * (.12 + i * .13) +
          math.sin(t * math.pi * 2 + i) * 12;
      final path = Path()
        ..moveTo(-30, y)
        ..quadraticBezierTo(
          size.width * .38,
          y - 35,
          size.width + 40,
          y + 10,
        );
      canvas.drawPath(path, p);
    }

    final fill = Paint()..color = Brand.mint.withOpacity(.12);
    for (int i = 0; i < 16; i++) {
      final x = (i * 73 + t * 50) % (size.width + 60) - 30;
      final y = (i * 137) % size.height;
      canvas.drawCircle(Offset(x, y), 2 + (i % 3), fill);
    }
  }

  @override
  bool shouldRepaint(covariant LearningMotifPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
