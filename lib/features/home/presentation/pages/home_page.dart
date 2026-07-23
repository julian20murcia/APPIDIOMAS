import 'package:flutter/material.dart';

import '../../../../core/data/worlds_data.dart';
import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/learning_background.dart';

class HomePage extends StatelessWidget {
  final World world;
  final String level;
  final void Function(World) onWorldTap;
  final VoidCallback goMap;

  const HomePage({
    super.key,
    required this.world,
    required this.level,
    required this.onWorldTap,
    required this.goMap,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottom = media.padding.bottom;
    final height = media.size.height;
    final compact = height < 820;

    return Stack(
      children: [
        const LearningBackground(),

        Positioned.fill(
          child: CustomPaint(
            painter: const LearningMotifPainter(t: .4),
          ),
        ),

        SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              18,
              compact ? 12 : 16,
              18,
              bottom + 138,
            ),
            children: [
              _HomeTopBar(
                compact: compact,
              ),

              SizedBox(height: compact ? 16 : 18),

              _CurrentWorldCard(
                world: world,
                level: level,
                compact: compact,
                onTap: goMap,
              ),

              SizedBox(height: compact ? 20 : 22),

              _HomeSectionHeader(
                title: 'Mundos disponibles',
                action: 'Ver todos',
                onAction: () {},
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: compact ? 160 : 178,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: worlds.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = worlds[index];

                    return _WorldCard(
                      world: item,
                      active: item.id == world.id,
                      compact: compact,
                      onTap: () => onWorldTap(item),
                    );
                  },
                ),
              ),

              SizedBox(height: compact ? 18 : 20),

              SizedBox(
                height: compact ? 220 : 235,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _MissionSummaryCard(
                        compact: compact,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProgressCard(
                        world: world,
                        compact: compact,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  final bool compact;

  const _HomeTopBar({
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniLogo(
          fontSize: compact ? 28 : 31,
        ),

        const Spacer(),

        _MetricPill(
          icon: Icons.local_fire_department_rounded,
          title: 'Racha',
          value: '3 días',
          compact: compact,
        ),

        const SizedBox(width: 8),

        _MetricPill(
          icon: Icons.auto_awesome_rounded,
          title: 'XP',
          value: '1.420',
          compact: compact,
        ),
      ],
    );
  }
}

class _MiniLogo extends StatelessWidget {
  final double fontSize;

  const _MiniLogo({
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Lingo',
              style: TextStyle(
                color: Brand.white,
                fontSize: fontSize,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.35,
              ),
            ),
            TextSpan(
              text: 'Verse',
              style: TextStyle(
                color: Brand.mint,
                fontSize: fontSize,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool compact;

  const _MetricPill({
    required this.icon,
    required this.title,
    required this.value,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 45 : 50,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 11 : 13,
      ),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.58),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Brand.white.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            spreadRadius: -12,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Brand.mint,
            size: compact ? 17 : 19,
          ),

          const SizedBox(width: 8),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Brand.white.withOpacity(0.58),
                  fontSize: compact ? 10.5 : 11.3,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: TextStyle(
                  color: Brand.white,
                  fontSize: compact ? 13 : 14.5,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentWorldCard extends StatelessWidget {
  final World world;
  final String level;
  final bool compact;
  final VoidCallback onTap;

  const _CurrentWorldCard({
    required this.world,
    required this.level,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 150 : 164,
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.60),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Brand.white.withOpacity(0.11),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.26),
            blurRadius: 28,
            spreadRadius: -15,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 94 : 108,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Brand.bgDeep.withOpacity(0.34),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Brand.white.withOpacity(0.08),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Image.asset(
                world.image,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          SizedBox(width: compact ? 14 : 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mundo actual',
                  style: TextStyle(
                    color: Brand.white.withOpacity(0.58),
                    fontSize: compact ? 12.2 : 13,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  '${world.language} · ${world.city}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Brand.white,
                    fontSize: compact ? 21 : 24,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -0.55,
                  ),
                ),

                SizedBox(height: compact ? 13 : 15),

                Row(
                  children: [
                    const Expanded(
                      child: _ProgressLine(
                        value: 0.45,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '45%',
                      style: TextStyle(
                        color: Brand.mint,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      level,
                      style: const TextStyle(
                        color: Brand.mint,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                _ContinueButton(
                  compact: compact,
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

class _ProgressLine extends StatelessWidget {
  final double value;

  const _ProgressLine({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Brand.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        widthFactor: value,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Brand.mint,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final bool compact;
  final VoidCallback onTap;

  const _ContinueButton({
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: compact ? 45 : 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Brand.mint,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Brand.mint.withOpacity(0.28),
                blurRadius: 22,
                spreadRadius: -9,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continuar misión',
                style: TextStyle(
                  color: Brand.bgDeep,
                  fontSize: compact ? 15 : 16.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.15,
                ),
              ),
              const SizedBox(width: 9),
              const Icon(
                Icons.sports_esports_rounded,
                color: Brand.bgDeep,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const _HomeSectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Brand.white,
              fontSize: 24,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.55,
            ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: Brand.mint,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Ver todos',
            style: TextStyle(
              color: Brand.mint,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _WorldCard extends StatelessWidget {
  final World world;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  const _WorldCard({
    required this.world,
    required this.active,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = compact ? 132.0 : 148.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: width,
          padding: EdgeInsets.all(compact ? 10 : 12),
          decoration: BoxDecoration(
            color: active ? Brand.mint : Brand.bgPanel.withOpacity(0.50),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: active ? Brand.mint : Brand.white.withOpacity(0.10),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Brand.mint.withOpacity(0.22),
                      blurRadius: 24,
                      spreadRadius: -10,
                      offset: const Offset(0, 14),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 22,
                      spreadRadius: -13,
                      offset: const Offset(0, 14),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    world.image,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

              const SizedBox(height: 9),

              Text(
                world.language,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? Brand.bgDeep : Brand.white,
                  fontSize: compact ? 16.5 : 18.5,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.32,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                world.city,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active
                      ? Brand.bgDeep.withOpacity(0.78)
                      : Brand.white.withOpacity(0.62),
                  fontSize: compact ? 12.5 : 13.5,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionSummaryCard extends StatelessWidget {
  final bool compact;

  const _MissionSummaryCard({
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return _SmallHomeCard(
      compact: compact,
      title: 'Misiones diarias',
      subtitle: '2/3 completas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MissionLine(
            title: 'Practica 10 frases',
            reward: '+20 XP',
            progress: 0.72,
          ),
          SizedBox(height: compact ? 13 : 15),
          const _MissionLine(
            title: 'Completa 5 diálogos',
            reward: '+15 XP',
            progress: 0.45,
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final World world;
  final bool compact;

  const _ProgressCard({
    required this.world,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return _SmallHomeCard(
      compact: compact,
      title: 'Tu avance',
      subtitle: '45% completado',
      child: Column(
        children: [
          SizedBox(
            height: compact ? 82 : 92,
            child: Image.asset(
              world.image,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 10),
          const _ProgressLine(value: 0.45),
        ],
      ),
    );
  }
}

class _SmallHomeCard extends StatelessWidget {
  final bool compact;
  final String title;
  final String subtitle;
  final Widget child;

  const _SmallHomeCard({
    required this.compact,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.50),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Brand.white.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.19),
            blurRadius: 22,
            spreadRadius: -13,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Brand.white,
              fontSize: compact ? 16.5 : 18,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Brand.white.withOpacity(0.62),
              fontSize: compact ? 12.5 : 13.4,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          SizedBox(height: compact ? 14 : 16),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _MissionLine extends StatelessWidget {
  final String title;
  final String reward;
  final double progress;

  const _MissionLine({
    required this.title,
    required this.reward,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Brand.white,
                  fontSize: 12.3,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              reward,
              style: TextStyle(
                color: Brand.white.withOpacity(0.68),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ProgressLine(value: progress),
      ],
    );
  }
}