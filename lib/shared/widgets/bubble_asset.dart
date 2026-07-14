import 'package:flutter/material.dart';

class BubbleAsset extends StatelessWidget {
  final String asset;
  final double width;
  final double angle;

  const BubbleAsset(
    this.asset, {
    super.key,
    required this.width,
    this.angle = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Image.asset(asset, width: width),
    );
  }
}
