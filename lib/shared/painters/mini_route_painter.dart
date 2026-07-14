import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class MiniRoutePainter extends CustomPainter {
  final bool active;

  const MiniRoutePainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 3 : 2
      ..strokeCap = StrokeCap.round
      ..color = (active ? Brand.mint : Brand.white).withOpacity(active ? .55 : .18);

    final path = Path()
      ..moveTo(size.width * .12, size.height * .73)
      ..cubicTo(
        size.width * .32,
        size.height * .45,
        size.width * .62,
        size.height * .86,
        size.width * .82,
        size.height * .55,
      );

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant MiniRoutePainter oldDelegate) {
    return oldDelegate.active != active;
  }
}
