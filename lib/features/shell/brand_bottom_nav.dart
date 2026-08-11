import 'package:flutter/material.dart';

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
    final media = MediaQuery.of(context);

    final width = media.size.width;
    final height = media.size.height;

    final compact = height < 820;
    final narrow = width < 370;

    final navHeight = compact ? 68.0 : 74.0;

    const items = [
      _NavItem(
        icon: Icons.home_rounded,
        label: 'Inicio',
      ),
      _NavItem(
        icon: Icons.public_rounded,
        label: 'Mundos',
      ),
      _NavItem(
        icon: Icons.auto_graph_rounded,
        label: 'Avance',
      ),
      _NavItem(
        icon: Icons.person_rounded,
        label: 'Perfil',
      ),
    ];

    return Container(
      height: navHeight,
      padding: EdgeInsets.all(
        compact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: _NavColors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(
          compact ? 24 : 27,
        ),
        border: Border.all(
          color: _NavColors.navy.withOpacity(0.055),
        ),
        boxShadow: [
          BoxShadow(
            color: _NavColors.navy.withOpacity(0.11),
            blurRadius: 30,
            spreadRadius: -13,
            offset: const Offset(0, 17),
          ),
          BoxShadow(
            color: _NavColors.gold.withOpacity(0.05),
            blurRadius: 24,
            spreadRadius: -15,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          items.length,
          (i) {
            return Expanded(
              child: _BottomNavButton(
                item: items[i],
                active: index == i,
                compact: compact,
                narrow: narrow,
                onTap: () => onTap(i),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final bool compact;
  final bool narrow;
  final VoidCallback onTap;

  const _BottomNavButton({
    required this.item,
    required this.active,
    required this.compact,
    required this.narrow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(
      compact ? 19 : 21,
    );

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 230,
          ),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(
            horizontal: narrow ? 2 : 3,
            vertical: 2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: narrow ? 2 : 4,
          ),
          decoration: BoxDecoration(
            color: active
                ? _NavColors.navy
                : Colors.transparent,
            borderRadius: radius,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _NavColors.navy.withOpacity(0.18),
                      blurRadius: 18,
                      spreadRadius: -9,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                duration: const Duration(
                  milliseconds: 220,
                ),
                opacity: active ? 1 : 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 24,
                    height: 3,
                    decoration: BoxDecoration(
                      color: _NavColors.gold,
                      borderRadius: BorderRadius.circular(
                        999,
                      ),
                    ),
                  ),
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 230,
                    ),
                    curve: Curves.easeOutCubic,
                    width: active
                        ? compact
                            ? 31
                            : 34
                        : compact
                            ? 28
                            : 30,
                    height: active
                        ? compact
                            ? 31
                            : 34
                        : compact
                            ? 28
                            : 30,
                    decoration: BoxDecoration(
                      color: active
                          ? _NavColors.gold.withOpacity(0.13)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: active
                          ? _NavColors.goldLight
                          : _NavColors.slate.withOpacity(0.72),
                      size: compact ? 21 : 23,
                    ),
                  ),

                  SizedBox(
                    height: compact ? 2 : 3,
                  ),

                  AnimatedDefaultTextStyle(
                    duration: const Duration(
                      milliseconds: 220,
                    ),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      color: active
                          ? _NavColors.white
                          : _NavColors.slate.withOpacity(0.72),
                      fontSize: narrow
                          ? 9.6
                          : compact
                              ? 10.3
                              : 11,
                      height: 1,
                      fontWeight: active
                          ? FontWeight.w800
                          : FontWeight.w600,
                      letterSpacing: -0.05,
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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

  const _NavItem({
    required this.icon,
    required this.label,
  });
}

abstract final class _NavColors {
  static const Color navy =
      Color(0xFF102A43);

  static const Color navyDeep =
      Color(0xFF081D30);

  static const Color slate =
      Color(0xFF627D98);

  static const Color gold =
      Color(0xFFD9A441);

  static const Color goldLight =
      Color(0xFFEBC66E);

  static const Color cream =
      Color(0xFFF4EDE2);

  static const Color ivory =
      Color(0xFFFAF7F1);

  static const Color white =
      Color(0xFFFFFFFF);
}