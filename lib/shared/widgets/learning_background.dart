import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class LearningBackground extends StatelessWidget {
  const LearningBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Brand.bgDeep),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Brand.purple.withOpacity(.18),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Brand.navy.withOpacity(.28),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -60,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Brand.bgPanel.withOpacity(.95),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
