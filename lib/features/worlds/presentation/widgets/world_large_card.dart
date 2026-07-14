import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/progress_bar.dart';

class WorldLargeCard extends StatelessWidget {
  final World world;
  final bool active;
  final VoidCallback onTap;

  const WorldLargeCard({
    super.key,
    required this.world,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        height: 190,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Brand.bgPanel.withOpacity(.70),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active ? Brand.mint : Brand.white.withOpacity(.10),
            width: active ? 2 : 1,
          ),
          boxShadow: active ? Brand.glowMint : Brand.cardShadow,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Hero(
                tag: 'world-${world.id}',
                child: Image.asset(world.image, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${world.flag} ${world.language}',
                    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    world.city,
                    style: const TextStyle(color: Brand.muted, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  const ProgressBar(value: .45),
                  const SizedBox(height: 12),
                  Text(
                    active ? 'Mundo activo' : 'Tocar para entrar',
                    style: TextStyle(
                      color: active ? Brand.mint : Brand.cyan,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
