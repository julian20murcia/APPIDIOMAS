import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/logo_mark.dart';

class LoginHeader extends StatelessWidget {
  final bool compact;

  const LoginHeader({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 720),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: compact ? -6 : -8,
                child: Container(
                  width: compact ? 92 : 112,
                  height: compact ? 28 : 34,
                  decoration: BoxDecoration(
                    color: Brand.mint.withOpacity(0.07),
                    borderRadius: Brand.radiusPill,
                    border: Border.all(
                      color: Brand.mint.withOpacity(0.12),
                    ),
                  ),
                ),
              ),

              LogoMark(
                center: true,
                size: compact ? 43 : 52,
              ),

              Positioned(
                right: compact ? -7 : -16,
                top: compact ? -8 : -10,
                child: _HeaderSparkBadge(
                  compact: compact,
                ),
              ),
            ],
          ),

          SizedBox(height: compact ? 6 : 9),

          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: compact ? 15.3 : 17,
                color: Brand.white.withOpacity(0.64),
                fontWeight: FontWeight.w600,
                height: 1.16,
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

          if (!compact) ...[
            const SizedBox(height: 9),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                'Completa misiones y desbloquea nuevas rutas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Brand.white.withOpacity(0.42),
                  fontSize: 12.8,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          SizedBox(height: compact ? 9 : 13),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeaderChip(
                icon: Icons.public_rounded,
                label: '5 mundos',
                compact: compact,
              ),
              SizedBox(width: compact ? 7 : 9),
              _HeaderChip(
                icon: Icons.route_rounded,
                label: 'Rutas',
                compact: compact,
              ),
              SizedBox(width: compact ? 7 : 9),
              _HeaderChip(
                icon: Icons.auto_awesome_rounded,
                label: 'Misiones',
                compact: compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderSparkBadge extends StatelessWidget {
  final bool compact;

  const _HeaderSparkBadge({
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 29.0 : 33.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Brand.bgPanel.withOpacity(0.92),
          shape: BoxShape.circle,
          border: Border.all(
            color: Brand.mint.withOpacity(0.30),
          ),
          boxShadow: Brand.glowMint,
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
          color: Brand.mint,
          size: compact ? 15 : 17,
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool compact;

  const _HeaderChip({
    required this.icon,
    required this.label,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 29 : 32,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 10,
      ),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.50),
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
            size: compact ? 13 : 14,
          ),
          SizedBox(width: compact ? 5 : 6),
          Text(
            label,
            style: TextStyle(
              color: Brand.white.withOpacity(0.72),
              fontSize: compact ? 10.8 : 11.6,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}