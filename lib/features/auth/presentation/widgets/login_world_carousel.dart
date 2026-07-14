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
  final bool compact;
  final ValueChanged<int> onChanged;

  const LoginWorldCarousel({
    super.key,
    required this.pageController,
    required this.current,
    required this.floatValue,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final height = compact
        ? screenHeight < 760
            ? 232.0
            : 252.0
        : 292.0;

    final bubbleScale = compact ? 0.82 : 1.0;
    final stripHeight = compact ? 32.0 : 38.0;

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
                compact: compact,
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
                    final scale = (1 - abs * 0.12).clamp(0.84, 1.0).toDouble();
                    final opacity = (1 - abs * 0.32).clamp(0.58, 1.0).toDouble();
                    final y = compact ? 10 * abs : 16 * abs;
                    final rotate = diff * -0.045;

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
                  top: compact ? 8 : 18,
                  left: compact ? 0 : 2,
                  width: 72 * bubbleScale,
                  angle: -0.12,
                  t: floatValue,
                  phase: 0.2,
                ),
                _FloatingBubble(
                  asset: 'assets/art/bubbles/salut.png',
                  top: compact ? 64 : 78,
                  right: compact ? 0 : 4,
                  width: 70 * bubbleScale,
                  angle: 0.10,
                  t: floatValue,
                  phase: 1.3,
                ),
                _FloatingBubble(
                  asset: 'assets/art/bubbles/ola.png',
                  bottom: compact ? 42 : 52,
                  left: compact ? 2 : 8,
                  width: 70 * bubbleScale,
                  angle: -0.08,
                  t: floatValue,
                  phase: 2.1,
                ),
                _FloatingBubble(
                  asset: 'assets/art/bubbles/hallo.png',
                  bottom: compact ? 34 : 42,
                  right: compact ? 0 : 6,
                  width: 74 * bubbleScale,
                  angle: 0.08,
                  t: floatValue,
                  phase: 3.2,
                ),
                _FloatingBubble(
                  asset: 'assets/art/bubbles/hello.png',
                  top: compact ? 86 : 104,
                  right: compact ? 92 : 112,
                  width: 80 * bubbleScale,
                  angle: 0.06,
                  t: floatValue,
                  phase: 4.4,
                ),

                Positioned(
                  left: compact ? 28 : 18,
                  right: compact ? 28 : 18,
                  bottom: compact ? 6 : 10,
                  child: _WorldRouteStrip(
                    current: current,
                    t: floatValue,
                    height: stripHeight,
                    compact: compact,
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
    final y = math.sin((t * math.pi * 2) + phase) * 6;
    final x = math.cos((t * math.pi * 2) + phase) * 3;

    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.translate(
        offset: Offset(x, y),
        child: Opacity(
          opacity: 0.90,
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
  final double height;
  final bool compact;

  const _WorldRouteStrip({
    required this.current,
    required this.t,
    required this.height,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
      ),
      decoration: BoxDecoration(
        color: Brand.bgDeep.withOpacity(0.54),
        borderRadius: Brand.radiusPill,
        border: Border.all(
          color: Brand.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
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
            final activeSize = compact ? 26.0 : 31.0;
            final inactiveSize = compact ? 21.0 : 25.0;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: active ? activeSize : inactiveSize,
              height: active ? activeSize : inactiveSize,
              decoration: BoxDecoration(
                color: active ? Brand.mint : Brand.bgPanel.withOpacity(0.90),
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? Brand.mint : Brand.white.withOpacity(0.12),
                  width: active ? 1.4 : 1,
                ),
                boxShadow: active ? Brand.glowMint : null,
              ),
              child: Center(
                child: Text(
                  worlds[index].flag,
                  style: TextStyle(
                    fontSize: active
                        ? compact
                            ? 13
                            : 16
                        : compact
                            ? 11
                            : 13,
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

    final start = Offset(16, size.height / 2);
    final end = Offset(size.width - 16, size.height / 2);

    final linePaint = Paint()
      ..color = Brand.white.withOpacity(0.08)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = Brand.mint.withOpacity(0.68)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, linePaint);

    final progress = current / (total - 1);
    final activeEnd = Offset(
      start.dx + (end.dx - start.dx) * progress,
      size.height / 2,
    );

    canvas.drawLine(start, activeEnd, activePaint);

    final particleX =
        start.dx + (end.dx - start.dx) * ((t + progress) % 1.0);

    canvas.drawCircle(
      Offset(particleX, size.height / 2),
      2.0,
      Paint()..color = Brand.cyan.withOpacity(0.82),
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
  final bool compact;

  _LoginCarouselRoutePainter({
    required this.t,
    required this.activeIndex,
    required this.total,
    required this.compact,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = compact ? 1.1 : 1.35
      ..strokeCap = StrokeCap.round
      ..color = Brand.mint.withOpacity(0.065);

    final cyanPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = Brand.cyan.withOpacity(0.045);

    final path = Path()
      ..moveTo(size.width * 0.04, size.height * 0.55)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.22,
        size.width * 0.42,
        size.height * 0.82,
        size.width * 0.61,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.24,
        size.width * 0.86,
        size.height * 0.62,
        size.width * 0.96,
        size.height * 0.38,
      );

    canvas.drawPath(path, routePaint);

    final topPath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.03,
        size.width * 0.88,
        size.height * 0.17,
      );

    canvas.drawPath(topPath, cyanPaint);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final dotPaint = Paint()
      ..color = Brand.cyan.withOpacity(0.66)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < total; i++) {
      final f = (t + i / total) % 1.0;
      final tangent = metric.getTangentForOffset(metric.length * f);
      if (tangent == null) continue;

      canvas.drawCircle(
        tangent.position,
        i == activeIndex ? 2.4 : 1.6,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LoginCarouselRoutePainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.total != total ||
        oldDelegate.compact != compact;
  }
}