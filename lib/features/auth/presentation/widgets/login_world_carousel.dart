import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/data/worlds_data.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/bubble_asset.dart';
import 'login_world_card.dart';

class LoginWorldCarousel extends StatelessWidget {
  final PageController pageController;
  final int current;
  final double floatValue;
  final ValueChanged<int> onChanged;

  const LoginWorldCarousel({
    super.key,
    required this.pageController,
    required this.current,
    required this.floatValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height < 760 ? 292.0 : 322.0;

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _LoginCarouselRoutePainter(
                t: floatValue,
                activeIndex: current,
                total: worlds.length,
              ),
            ),
          ),

          Positioned.fill(
            child: PageView.builder(
              controller: pageController,
              itemCount: worlds.length,
              onPageChanged: onChanged,
              physics: const BouncingScrollPhysics(),
              allowImplicitScrolling: true,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: pageController,
                  builder: (context, child) {
                    double diff = 0;

                    if (pageController.hasClients &&
                        pageController.position.haveDimensions) {
                      diff =
                          ((pageController.page ?? current.toDouble()) - index)
                              .toDouble();
                    } else {
                      diff = (current - index).toDouble();
                    }

                    final abs = diff.abs().clamp(0.0, 1.0).toDouble();
                    final scale = (1 - abs * 0.13).clamp(0.82, 1.0).toDouble();
                    final opacity = (1 - abs * 0.32).clamp(0.58, 1.0).toDouble();
                    final y = 18 * abs;
                    final rotate = diff * -0.055;

                    return Opacity(
                      opacity: opacity,
                      child: Transform.translate(
                        offset: Offset(0, y),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(rotate),
                          child: Transform.scale(
                            scale: scale,
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                  child: LoginWorldCard(
                    world: worlds[index],
                    active: current == index,
                  ),
                );
              },
            ),
          ),

          IgnorePointer(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _FloatingBubble(
                  asset: 'assets/art/bubbles/ciao.png',
                  top: 20,
                  left: 2,
                  width: 72,
                  angle: -0.12,
                  t: floatValue,
                  phase: 0.2,
                ),
                _FloatingBubble(
                  asset: 'assets/art/bubbles/salut.png',
                  top: 82,
                  right: 4,
                  width: 70,
                  angle: 0.10,
                  t: floatValue,
                  phase: 1.3,
                ),
                _FloatingBubble(
                  asset: 'assets/art/bubbles/ola.png',
                  bottom: 52,
                  left: 8,
                  width: 70,
                  angle: -0.08,
                  t: floatValue,
                  phase: 2.1,
                ),
                _FloatingBubble(
                  asset: 'assets/art/bubbles/hallo.png',
                  bottom: 42,
                  right: 6,
                  width: 74,
                  angle: 0.08,
                  t: floatValue,
                  phase: 3.2,
                ),
                _FloatingBubble(
                  asset: 'assets/art/bubbles/hello.png',
                  top: 108,
                  right: 112,
                  width: 80,
                  angle: 0.06,
                  t: floatValue,
                  phase: 4.4,
                ),

                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 14,
                  child: _WorldRouteStrip(
                    current: current,
                    t: floatValue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingBubble extends StatelessWidget {
  final String asset;
  final double width;
  final double angle;
  final double t;
  final double phase;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  const _FloatingBubble({
    required this.asset,
    required this.width,
    required this.angle,
    required this.t,
    required this.phase,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final y = math.sin((t * math.pi * 2) + phase) * 7;
    final x = math.cos((t * math.pi * 2) + phase) * 3;

    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.translate(
        offset: Offset(x, y),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 280),
          opacity: 0.94,
          child: BubbleAsset(
            asset,
            width: width,
            angle: angle,
          ),
        ),
      ),
    );
  }
}

class _WorldRouteStrip extends StatelessWidget {
  final int current;
  final double t;

  const _WorldRouteStrip({
    required this.current,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Brand.bgDeep.withOpacity(0.48),
        borderRadius: Brand.radiusPill,
        border: Border.all(
          color: Brand.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 18,
            spreadRadius: -10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _WorldRouteStripPainter(
          current: current,
          t: t,
          total: worlds.length,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(worlds.length, (index) {
            final active = current == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: active ? 31 : 25,
              height: active ? 31 : 25,
              decoration: BoxDecoration(
                color: active ? Brand.mint : Brand.bgPanel.withOpacity(0.88),
                shape: BoxShape.circle,
                border: Border.all(
                  color: active
                      ? Brand.mint
                      : Brand.white.withOpacity(0.12),
                  width: active ? 1.6 : 1,
                ),
                boxShadow: active ? Brand.glowMint : null,
              ),
              child: Center(
                child: Text(
                  worlds[index].flag,
                  style: TextStyle(
                    fontSize: active ? 16 : 13,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _WorldRouteStripPainter extends CustomPainter {
  final int current;
  final double t;
  final int total;

  _WorldRouteStripPainter({
    required this.current,
    required this.t,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 1) return;

    final linePaint = Paint()
      ..color = Brand.white.withOpacity(0.09)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = Brand.mint.withOpacity(0.72)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final start = Offset(20, size.height / 2);
    final end = Offset(size.width - 20, size.height / 2);

    canvas.drawLine(start, end, linePaint);

    final progress = total == 1 ? 0.0 : current / (total - 1);
    final activeEnd = Offset(
      start.dx + (end.dx - start.dx) * progress,
      size.height / 2,
    );

    canvas.drawLine(start, activeEnd, activePaint);

    final particlePaint = Paint()
      ..color = Brand.cyan.withOpacity(0.90)
      ..style = PaintingStyle.fill;

    final particleX =
        start.dx + (end.dx - start.dx) * ((t + progress) % 1.0);

    canvas.drawCircle(
      Offset(particleX, size.height / 2),
      2.2,
      particlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WorldRouteStripPainter oldDelegate) {
    return oldDelegate.current != current ||
        oldDelegate.t != t ||
        oldDelegate.total != total;
  }
}

class _LoginCarouselRoutePainter extends CustomPainter {
  final double t;
  final int activeIndex;
  final int total;

  _LoginCarouselRoutePainter({
    required this.t,
    required this.activeIndex,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = Brand.mint.withOpacity(0.075);

    final cyanPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = Brand.cyan.withOpacity(0.05);

    final path = Path()
      ..moveTo(size.width * 0.04, size.height * 0.56)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.20,
        size.width * 0.42,
        size.height * 0.83,
        size.width * 0.61,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.23,
        size.width * 0.86,
        size.height * 0.64,
        size.width * 0.96,
        size.height * 0.38,
      );

    canvas.drawPath(path, routePaint);

    final pathTwo = Path()
      ..moveTo(size.width * 0.12, size.height * 0.20)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.02,
        size.width * 0.88,
        size.height * 0.18,
      );

    canvas.drawPath(pathTwo, cyanPaint);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final dotPaint = Paint()
      ..color = Brand.cyan.withOpacity(0.72)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final f = (t + i / 6) % 1.0;
      final tangent = metric.getTangentForOffset(metric.length * f);
      if (tangent == null) continue;
      canvas.drawCircle(tangent.position, i == activeIndex ? 2.8 : 1.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LoginCarouselRoutePainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.total != total;
  }
}