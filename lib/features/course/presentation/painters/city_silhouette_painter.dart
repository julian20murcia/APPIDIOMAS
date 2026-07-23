import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';

class CitySilhouettePainter extends CustomPainter {
  final World world;

  const CitySilhouettePainter({
    required this.world,
  });

  int get _seed {
    var value = 0;
    for (final code in world.id.codeUnits) {
      value = value + code;
    }
    return value;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    _drawSoftGlows(canvas, size);
    _drawRouteAtmosphere(canvas, size);
    _drawDistantCity(canvas, size);
    _drawGroundMist(canvas, size);
    _drawTinyStars(canvas, size);
  }

  void _drawSoftGlows(Canvas canvas, Size size) {
    final topGlow = Paint()
      ..color = Brand.cyan.withOpacity(0.055)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        36,
      );

    final mintGlow = Paint()
      ..color = Brand.mint.withOpacity(0.045)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        44,
      );

    final purpleGlow = Paint()
      ..color = Brand.purple.withOpacity(0.16)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        48,
      );

    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.12),
      size.width * 0.42,
      topGlow,
    );

    canvas.drawCircle(
      Offset(size.width * 0.20, size.height * 0.48),
      size.width * 0.28,
      purpleGlow,
    );

    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.72),
      size.width * 0.24,
      mintGlow,
    );
  }

  void _drawRouteAtmosphere(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Brand.white.withOpacity(0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(size.width * 0.08, size.height * 0.18)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.10,
        size.width * 0.52,
        size.height * 0.22,
        size.width * 0.78,
        size.height * 0.14,
      );

    final path2 = Path()
      ..moveTo(size.width * 0.02, size.height * 0.62)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.55,
        size.width * 0.64,
        size.height * 0.70,
        size.width * 0.98,
        size.height * 0.58,
      );

    canvas.drawPath(path1, linePaint);
    canvas.drawPath(path2, linePaint);
  }

  void _drawDistantCity(Canvas canvas, Size size) {
    final rnd = math.Random(_seed);

    final baseY = size.height * 0.84;

    final backPaint = Paint()
      ..color = Brand.navy.withOpacity(0.16)
      ..style = PaintingStyle.fill;

    final frontPaint = Paint()
      ..color = Brand.bgDeep.withOpacity(0.24)
      ..style = PaintingStyle.fill;

    final windowPaint = Paint()
      ..color = Brand.mint.withOpacity(0.075)
      ..style = PaintingStyle.fill;

    final buildingCount = 13;
    final spacing = size.width / (buildingCount - 1);

    for (int i = 0; i < buildingCount; i++) {
      final width = 24.0 + rnd.nextInt(20);
      final height = 54.0 + rnd.nextInt(82);
      final x = (i * spacing) - (width / 2);
      final y = baseY - height;

      final radius = Radius.circular(
        i.isEven ? 10 : 7,
      );

      final building = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          y,
          width,
          height,
        ),
        radius,
      );

      canvas.drawRRect(
        building,
        i.isEven ? backPaint : frontPaint,
      );

      if (i % 3 != 0) {
        final rows = math.max(2, (height / 28).floor());
        for (int r = 0; r < rows; r++) {
          final wy = y + 14 + (r * 20);
          if (wy > baseY - 12) continue;

          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                x + width * 0.34,
                wy,
                4,
                4,
              ),
              const Radius.circular(2),
            ),
            windowPaint,
          );

          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                x + width * 0.58,
                wy,
                4,
                4,
              ),
              const Radius.circular(2),
            ),
            windowPaint,
          );
        }
      }
    }
  }

  void _drawGroundMist(Canvas canvas, Size size) {
    final mistPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Brand.bgPanel.withOpacity(0.00),
          Brand.bgDeep.withOpacity(0.24),
          Brand.bgDeep.withOpacity(0.38),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          size.height * 0.70,
          size.width,
          size.height * 0.30,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height * 0.70,
        size.width,
        size.height * 0.30,
      ),
      mistPaint,
    );

    final linePaint = Paint()
      ..color = Brand.white.withOpacity(0.04)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 5; i++) {
      final y = size.height * (0.78 + i * 0.035);

      canvas.drawLine(
        Offset(size.width * 0.08, y),
        Offset(size.width * 0.92, y),
        linePaint,
      );
    }
  }

  void _drawTinyStars(Canvas canvas, Size size) {
    final rnd = math.Random(_seed + 99);

    final starPaint = Paint()
      ..color = Brand.white.withOpacity(0.22)
      ..style = PaintingStyle.fill;

    final mintStarPaint = Paint()
      ..color = Brand.mint.withOpacity(0.16)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 18; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = size.height * 0.06 + rnd.nextDouble() * size.height * 0.58;
      final radius = i % 5 == 0 ? 1.3 : 0.85;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        i % 4 == 0 ? mintStarPaint : starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CitySilhouettePainter oldDelegate) {
    return oldDelegate.world.id != world.id;
  }
}