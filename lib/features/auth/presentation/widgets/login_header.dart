import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/logo_mark.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 780),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -8,
                child: Container(
                  width: 112,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Brand.mint.withOpacity(0.08),
                    borderRadius: Brand.radiusPill,
                    border: Border.all(
                      color: Brand.mint.withOpacity(0.14),
                    ),
                  ),
                ),
              ),

              const LogoMark(
                center: true,
                size: 54,
              ),

              Positioned(
                right: -18,
                top: -10,
                child: _HeaderSparkBadge(),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 17.5,
                color: Brand.white.withOpacity(0.64),
                fontWeight: FontWeight.w600,
                height: 1.18,
                letterSpacing: -0.1,
              ),
              children: const [
                TextSpan(text: 'Aprende jugando, '),
                TextSpan(
                  text: 'explora el mundo',
                  style: TextStyle(
                    color: Brand.mint,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 14),

          Text(
            'Elige un idioma, completa misiones y desbloquea nuevas rutas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Brand.white.withOpacity(0.44),
              fontSize: 13.2,
              height: 1.32,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeaderChip(
                icon: Icons.public_rounded,
                label: '5 mundos',
              ),
              SizedBox(width: 9),
              _HeaderChip(
                icon: Icons.route_rounded,
                label: 'Rutas',
              ),
              SizedBox(width: 9),
              _HeaderChip(
                icon: Icons.auto_awesome_rounded,
                label: 'Misiones',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderSparkBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Brand.bgPanel.withOpacity(0.92),
          shape: BoxShape.circle,
          border: Border.all(
            color: Brand.mint.withOpacity(0.32),
          ),
          boxShadow: Brand.glowMint,
        ),
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: Brand.mint,
          size: 18,
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.54),
        borderRadius: Brand.radiusPill,
        border: Border.all(
          color: Brand.white.withOpacity(0.09),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Brand.mint,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Brand.white.withOpacity(0.74),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}