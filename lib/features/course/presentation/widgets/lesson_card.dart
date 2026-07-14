import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

class LessonCard extends StatelessWidget {
  final String title;
  final bool unlocked;
  final bool start;

  const LessonCard({
    super.key,
    required this.title,
    required this.unlocked,
    this.start = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: unlocked ? Brand.cyan.withOpacity(.55) : Brand.white.withOpacity(.08),
        ),
        boxShadow: Brand.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (start)
            const Text(
              'Â¡Empieza aquÃ­!',
              style: TextStyle(color: Brand.mint, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, height: 1.25),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(unlocked ? Icons.check_circle : Icons.lock, color: unlocked ? Brand.mint : Brand.muted, size: 19),
              const SizedBox(width: 6),
              Text(
                unlocked ? 'Completado' : 'Bloqueado',
                style: TextStyle(color: unlocked ? Brand.mint : Brand.muted, fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
