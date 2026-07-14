import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';

class CitySilhouettePainter extends CustomPainter {
  final World world;

  const CitySilhouettePainter({required this.world});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Brand.navy.withOpacity(.28);
    final rnd = math.Random(world.id.hashCode);

    for (int i = 0; i < 12; i++) {
      final w = 38.0 + rnd.nextInt(40);
      final h = 140.0 + rnd.nextInt(240);
      final x = rnd.nextDouble() * size.width;
      final y = 170.0 + rnd.nextDouble() * (size.height - 260);
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(10),
      );
      canvas.drawRRect(r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CitySilhouettePainter oldDelegate) {
    return oldDelegate.world != world;
  }
}
