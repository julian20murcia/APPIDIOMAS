import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

class LessonNode extends StatelessWidget {
  final int number;
  final bool unlocked;

  const LessonNode({
    super.key,
    required this.number,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: unlocked ? Brand.mintDark : Brand.line,
        border: Border.all(color: Brand.white, width: 3),
        boxShadow: unlocked ? Brand.glowMint : null,
      ),
      child: Center(
        child: unlocked
            ? Text(
                '$number',
                style: const TextStyle(
                  fontSize: 28,
                  color: Brand.bgDeep,
                  fontWeight: FontWeight.w900,
                ),
              )
            : const Icon(Icons.lock_rounded, color: Brand.white),
      ),
    );
  }
}
