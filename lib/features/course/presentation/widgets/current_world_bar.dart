import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/progress_bar.dart';

class CurrentWorldBar extends StatelessWidget {
  final World world;
  final String level;
  final VoidCallback onChange;

  const CurrentWorldBar({
    super.key,
    required this.world,
    required this.level,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.58),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Brand.white.withOpacity(.10)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 80,
              height: 80,
              color: Brand.bgDeep,
              child: Image.asset(world.image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Mundo actual',
                  style: TextStyle(color: Brand.muted, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${world.language} Â· ${world.city}',
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Expanded(child: ProgressBar(value: .45)),
                    const SizedBox(width: 9),
                    const Text('45%', style: TextStyle(color: Brand.muted, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Text(level, style: const TextStyle(color: Brand.mint, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onChange,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Brand.navy.withOpacity(.45),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(Icons.map_rounded, color: Brand.mint, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
