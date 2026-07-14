import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/progress_bar.dart';

class ProgressSummary extends StatelessWidget {
  final World world;
  final bool large;

  const ProgressSummary({
    super.key,
    required this.world,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.68),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Brand.white.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tu avance', style: TextStyle(fontSize: large ? 24 : 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Center(child: Image.asset(world.image, height: large ? 210 : 94)),
          const SizedBox(height: 10),
          const Text('45% completado', style: TextStyle(color: Brand.mint, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const ProgressBar(value: .45),
        ],
      ),
    );
  }
}
