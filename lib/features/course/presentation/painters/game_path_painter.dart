import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

class GamePathPainter extends CustomPainter {
  final double progress;

  const GamePathPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final pts = [
      Offset(size.width * .23, 315),
      Offset(size.width * .72, 405),
      Offset(size.width * .25, 555),
      Offset(size.width * .72, 705),
      Offset(size.width * .25, 855),
      Offset(size.width * .67, 965),
    ];

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      path.cubicTo(a.dx, (a.dy + b.dy) / 2, b.dx, (a.dy + b.dy) / 2, b.dx, b.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 50
        ..strokeCap = StrokeCap.round
        ..color = Brand.purple.withOpacity(.55),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 32
        ..strokeCap = StrokeCap.round
        ..color = Brand.purple.withOpacity(.88),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Brand.mint.withOpacity(.92),
    );

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    for (int i = 0; i < 18; i++) {
      final f = (progress + i / 18) % 1;
      final pos = metric.getTangentForOffset(metric.length * f)?.position;
      if (pos != null) {
        canvas.drawCircle(pos, 2.4, Paint()..color = Brand.cyan.withOpacity(.85));
      }
    }
  }

  @override
  bool shouldRepaint(covariant GamePathPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
