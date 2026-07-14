import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class BrandBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const BrandBottomNav({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.home_rounded, 'Inicio'),
      _NavItem(Icons.public_rounded, 'Mundos'),
      _NavItem(Icons.auto_graph_rounded, 'Avance'),
      _NavItem(Icons.person_rounded, 'Perfil'),
    ];

    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Brand.white.withOpacity(.10)),
        boxShadow: Brand.cardShadow,
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = index == i || (i == 1 && index == 2);
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: active ? Brand.mint : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: active ? Brand.glowMint : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[i].icon,
                      color: active ? Brand.bgDeep : Brand.white.withOpacity(.55),
                      size: 25,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        color: active ? Brand.bgDeep : Brand.white.withOpacity(.58),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
