import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/progress_bar.dart';

class CompactWorldHeader extends StatelessWidget {
  final World world;
  final String level;
  final VoidCallback onTap;

  const CompactWorldHeader({
    super.key,
    required this.world,
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Brand.white.withOpacity(.09)),
        boxShadow: Brand.cardShadow,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 88,
              height: 88,
              color: Brand.bgDeep.withOpacity(.55),
              child: Image.asset(world.image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mundo actual',
                  style: TextStyle(color: Brand.muted, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  '${world.language} Â· ${world.city}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(child: ProgressBar(value: .45)),
                    const SizedBox(width: 10),
                    Text(
                      '45%  $level',
                      style: const TextStyle(color: Brand.mint, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Continuar misiÃ³n',
                  icon: Icons.sports_esports_rounded,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
