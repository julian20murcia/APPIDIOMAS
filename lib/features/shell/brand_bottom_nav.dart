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
    final height = MediaQuery.of(context).size.height;
    final compact = height < 820;

    final navHeight = compact ? 70.0 : 76.0;

    const items = [
      _NavItem(Icons.home_rounded, 'Inicio'),
      _NavItem(Icons.public_rounded, 'Mundos'),
      _NavItem(Icons.auto_graph_rounded, 'Avance'),
      _NavItem(Icons.person_rounded, 'Perfil'),
    ];

    return Container(
      height: navHeight,
      padding: EdgeInsets.all(compact ? 6 : 7),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.88),
        borderRadius: BorderRadius.circular(compact ? 26 : 30),
        border: Border.all(
          color: Brand.white.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 28,
            spreadRadius: -14,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Brand.mint.withOpacity(0.05),
            blurRadius: 34,
            spreadRadius: -18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = index == i;

          return Expanded(
            child: _BottomNavButton(
              item: items[i],
              active: active,
              compact: compact,
              onTap: () => onTap(i),
            ),
          );
        }),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  const _BottomNavButton({
    required this.item,
    required this.active,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? 21 : 23);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(
            horizontal: compact ? 3 : 4,
            vertical: compact ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: active ? Brand.mint : Colors.transparent,
            borderRadius: radius,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Brand.mint.withOpacity(0.26),
                      blurRadius: 20,
                      spreadRadius: -9,
                      offset: const Offset(0, 11),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: active ? Brand.bgDeep : Brand.white.withOpacity(0.58),
                size: compact ? 22 : 24,
              ),

              SizedBox(height: compact ? 2 : 3),

              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? Brand.bgDeep : Brand.white.withOpacity(0.58),
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 10.8 : 11.5,
                  height: 1,
                  letterSpacing: -0.08,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}