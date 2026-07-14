import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class LogoMark extends StatelessWidget {
  final bool center;
  final double size;

  const LogoMark({
    super.key,
    this.center = false,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: center ? Alignment.center : Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            letterSpacing: -2.4,
            height: 1,
          ),
          children: const [
            TextSpan(text: 'Lingo', style: TextStyle(color: Brand.white)),
            TextSpan(text: 'Verse', style: TextStyle(color: Brand.mint)),
          ],
        ),
      ),
    );
  }
}
