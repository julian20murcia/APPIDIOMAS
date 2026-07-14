import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';

class WorldMiniCard extends StatelessWidget {
  final World world;
  final bool active;
  final VoidCallback onTap;

  const WorldMiniCard({
    super.key,
    required this.world,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? Brand.mint : Brand.bgPanel.withOpacity(.64),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: active ? Brand.mint : Brand.white.withOpacity(.10),
          ),
          boxShadow: active ? Brand.glowMint : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Center(child: Image.asset(world.image, fit: BoxFit.contain))),
            Text(
              world.language,
              style: TextStyle(
                color: active ? Brand.bgDeep : Brand.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              world.city,
              style: TextStyle(
                color: active ? Brand.bgDeep.withOpacity(.75) : Brand.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
