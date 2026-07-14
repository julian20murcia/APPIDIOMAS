import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

class FinalChallengeCard extends StatelessWidget {
  const FinalChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Brand.white.withOpacity(.08)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reto final', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          SizedBox(height: 6),
          Text('Completa para ganar XP extra ðŸ’Ž', style: TextStyle(color: Brand.muted, height: 1.3)),
        ],
      ),
    );
  }
}
