import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

class GamePathPainter extends CustomPainter {
  final double progress;

  const GamePathPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final compact = size.height < 1010;

    final nodeSize = 70.0;
    final nodeCenter = nodeSize / 2;

    final leftX = size.width * 0.17 + nodeCenter;
    final rightX = size.width * 0.72 + nodeCenter;

    final points = [
      Offset(leftX, compact ? 319 : 319),
      Offset(rightX, compact ? 440 : 440),
      Offset(leftX, compact ? 583 : 583),
      Offset(rightX, compact ? 725 : 725),
      Offset(leftX, compact ? 861 : 861),
      Offset(rightX, compact ? 963 : 963),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];

      final controlY = (a.dy + b.dy) / 2;
      final pull = i.isEven ? 42.0 : -42.0;

      path.cubicTo(
        a.dx + pull,
        controlY,
        b.dx - pull,
        controlY,
        b.dx,
        b.dy,
      );
    }

    _drawOuterGlow(canvas, path);
    _drawMainRoad(canvas, path);
    _drawInnerRoad(canvas, path);
    _drawCenterLine(canvas, path);
    _drawMovingDots(canvas, path);
  }

  void _drawOuterGlow(Canvas canvas, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 42
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Brand.purple.withOpacity(0.20)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          14,
        ),
    );
  }

  void _drawMainRoad(Canvas canvas, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 34
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Brand.purple.withOpacity(0.55),
    );
  }

  void _drawInnerRoad(Canvas canvas, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Brand.bgPanel.withOpacity(0.82),
    );
  }

  void _drawCenterLine(Canvas canvas, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Brand.mint.withOpacity(0.78),
    );
  }

  void _drawMovingDots(Canvas canvas, Path path) {
    final metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) return;

    final metric = metrics.first;

    final glowPaint = Paint()
      ..color = Brand.cyan.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        8,
      );

    final dotPaint = Paint()
      ..color = Brand.cyan.withOpacity(0.78);

    for (int i = 0; i < 14; i++) {
      final factor = (progress + i / 14) % 1;
      final tangent = metric.getTangentForOffset(metric.length * factor);

      if (tangent == null) continue;

      final pulse = 1 + math.sin((progress * math.pi * 2) + i) * 0.18;
      final radius = 2.1 * pulse;

      canvas.drawCircle(
        tangent.position,
        radius + 3.2,
        glowPaint,
      );

      canvas.drawCircle(
        tangent.position,
        radius,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GamePathPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}