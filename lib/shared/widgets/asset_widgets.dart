import 'dart:math' as math;

import 'package:flutter/material.dart';

class DecorImage extends StatelessWidget {
  final String asset;
  final double width;
  final double opacity;

  const DecorImage(
    this.asset, {
    super.key,
    required this.width,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Image.asset(asset, width: width),
    );
  }
}

class FloatingAsset extends StatelessWidget {
  final String asset;
  final double width;
  final double t;

  const FloatingAsset(
    this.asset, {
    super.key,
    required this.width,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, math.sin(t * math.pi * 2) * 8),
      child: Image.asset(asset, width: width),
    );
  }
}
