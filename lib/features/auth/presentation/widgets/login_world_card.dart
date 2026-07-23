import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/painters/mini_route_painter.dart';

class LoginWorldCard extends StatelessWidget {
  final World world;
  final bool active;

  const LoginWorldCard({
    super.key,
    required this.world,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: active ? 1 : 0,
      ),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(
            horizontal: active ? 2 : 8,
            vertical: active ? 0 : 22,
          ),
          decoration: BoxDecoration(
            color: Color.lerp(
              Brand.bgPanel.withOpacity(0.38),
              Brand.bgPanel.withOpacity(0.68),
              value,
            ),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: Color.lerp(
                Brand.white.withOpacity(0.10),
                Brand.mint.withOpacity(0.70),
                value,
              )!,
              width: active ? 1.5 : 1,
            ),
            boxShadow: active ? Brand.activeWorldShadow : Brand.softShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: MiniRoutePainter(active: active),
                  ),
                ),

                Positioned(
                  top: -38,
                  right: -34,
                  child: Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Brand.purple.withOpacity(active ? 0.18 : 0.08),
                    ),
                  ),
                ),

                Positioned(
                  left: -42,
                  bottom: -46,
                  child: Container(
                    width: 142,
                    height: 142,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Brand.navy.withOpacity(active ? 0.22 : 0.10),
                    ),
                  ),
                ),

                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: _WorldBadge(
                    world: world,
                    active: active,
                  ),
                ),

                Positioned(
                  top: 72,
                  left: 18,
                  right: 18,
                  child: _WorldCopy(
                    world: world,
                    active: active,
                  ),
                ),

                Positioned(
                  left: 4,
                  right: 4,
                  bottom: 18,
                  top: 110,
                  child: Hero(
                    tag: 'world-${world.id}',
                    child: _SafeAssetImage(
                      asset: world.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                Positioned(
                  right: 16,
                  bottom: 18,
                  child: _HelloChip(
                    text: world.hello,
                    active: active,
                  ),
                ),

                if (world.hasSecondaryAsset)
                  Positioned(
                    left: 18,
                    bottom: 22,
                    child: Opacity(
                      opacity: active ? 0.92 : 0.46,
                      child: _SafeAssetImage(
                        asset: world.secondaryAsset,
                        width: 38,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                Positioned(
                  right: 18,
                  top: 112,
                  child: _FloatingMiniIcon(
                    active: active,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WorldBadge extends StatelessWidget {
  final World world;
  final bool active;

  const _WorldBadge({
    required this.world,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: Brand.bgDeep.withOpacity(active ? 0.72 : 0.52),
            borderRadius: Brand.radiusPill,
            border: Border.all(
              color: active
                  ? Brand.mint.withOpacity(0.36)
                  : Brand.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                world.flag,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 7),
              Text(
                world.language,
                style: const TextStyle(
                  color: Brand.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: active ? Brand.mint : Brand.bgDeep.withOpacity(0.58),
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? Brand.mint : Brand.white.withOpacity(0.08),
            ),
            boxShadow: active ? Brand.glowMint : null,
          ),
          child: Icon(
            Icons.route_rounded,
            color: active ? Brand.bgDeep : Brand.white.withOpacity(0.54),
            size: 19,
          ),
        ),
      ],
    );
  }
}

class _WorldCopy extends StatelessWidget {
  final World world;
  final bool active;

  const _WorldCopy({
    required this.world,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final keywords = world.keywords.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          world.city,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Brand.white.withOpacity(active ? 0.96 : 0.68),
            fontSize: 21,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          world.safeThemeName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? Brand.mint : Brand.white.withOpacity(0.46),
            fontSize: 12.2,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
        ),

        if (keywords.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: keywords.map((keyword) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Brand.bgDeep.withOpacity(0.42),
                  borderRadius: Brand.radiusPill,
                  border: Border.all(
                    color: Brand.white.withOpacity(0.08),
                  ),
                ),
                child: Text(
                  keyword,
                  style: TextStyle(
                    color: Brand.white.withOpacity(active ? 0.72 : 0.46),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _HelloChip extends StatelessWidget {
  final String text;
  final bool active;

  const _HelloChip({
    required this.text,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: active ? Brand.mint : Brand.bgDeep.withOpacity(0.74),
        borderRadius: Brand.radiusPill,
        border: Border.all(
          color: active ? Brand.mint : Brand.white.withOpacity(0.10),
        ),
        boxShadow: active ? Brand.glowMint : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Brand.bgDeep : Brand.white.withOpacity(0.74),
          fontSize: 12.6,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FloatingMiniIcon extends StatelessWidget {
  final bool active;

  const _FloatingMiniIcon({
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 260),
      opacity: active ? 1 : 0.35,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Brand.cyan.withOpacity(active ? 0.18 : 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: Brand.cyan.withOpacity(active ? 0.24 : 0.10),
          ),
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
          color: active ? Brand.cyan : Brand.white.withOpacity(0.34),
          size: 16,
        ),
      ),
    );
  }
}

class _SafeAssetImage extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;

  const _SafeAssetImage({
    required this.asset,
    this.width,
    this.fit = BoxFit.contain,
  }) : height = null;

  @override
  Widget build(BuildContext context) {
    if (asset.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}