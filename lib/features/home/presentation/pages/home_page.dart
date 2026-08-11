import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/data/worlds_data.dart';
import '../../../../core/models/world.dart';

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

  int get _completedLessons {
    if (world.lessons.isEmpty) return 0;

    return math.min(
      4,
      world.lessons.length,
    );
  }

  double get _progress {
    if (world.lessons.isEmpty) return 0;

    return (_completedLessons / world.lessons.length)
        .clamp(0.0, 1.0);
  }

  String get _nextLesson {
    if (world.lessons.isEmpty) {
      return 'Lección inicial';
    }

    if (_completedLessons >= world.lessons.length) {
      return 'Curso completado';
    }

    return world.lessons[_completedLessons];
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final width = media.size.width;
    final height = media.size.height;

    final compact = height < 820;
    final narrow = width < 370;

    return Stack(
      children: [
        const Positioned.fill(
          child: _HomeBackground(),
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _HomeDecorationPainter(),
            ),
          ),
        ),

        SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              narrow ? 14 : 18,
              compact ? 10 : 14,
              narrow ? 14 : 18,
              media.padding.bottom + 128,
            ),
            children: [
              _TopBar(
                compact: compact,
                narrow: narrow,
              ),

              SizedBox(
                height: compact ? 18 : 22,
              ),

              _WelcomeHeader(
                compact: compact,
              ),

              SizedBox(
                height: compact ? 16 : 20,
              ),

              _CurrentJourneyCard(
                world: world,
                level: level,
                compact: compact,
                completedLessons: _completedLessons,
                progress: _progress,
                onTap: goMap,
              ),

              SizedBox(
                height: compact ? 24 : 28,
              ),

              const _SectionHeader(
                title: 'Explora los mundos',
                subtitle:
                    'Cada idioma abre una nueva aventura.',
              ),

              const SizedBox(height: 13),

              SizedBox(
                height: compact ? 176 : 192,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: worlds.length,
                  separatorBuilder: (_, __) {
                    return const SizedBox(width: 12);
                  },
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final item = worlds[index];

                    return _WorldCard(
                      world: item,
                      selected:
                          item.id == world.id,
                      compact: compact,
                      onTap: () {
                        onWorldTap(item);
                      },
                    );
                  },
                ),
              ),

              SizedBox(
                height: compact ? 24 : 28,
              ),

              const _SectionHeader(
                title: 'Sigue avanzando',
                subtitle:
                    'Tu siguiente paso ya está listo.',
              ),

              const SizedBox(height: 13),

              _NextLessonCard(
                world: world,
                level: level,
                lesson: _nextLesson,
                completedLessons:
                    _completedLessons,
                totalLessons:
                    world.lessons.length,
                compact: compact,
                onTap: goMap,
              ),

              SizedBox(
                height: compact ? 18 : 22,
              ),

              _ActivityOverview(
                completedLessons:
                    _completedLessons,
                totalLessons:
                    world.lessons.length,
                compact: compact,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFEFB),
            Color(0xFFFAF7F1),
            Color(0xFFF3E9DB),
          ],
          stops: [
            0,
            0.58,
            1,
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool compact;
  final bool narrow;

  const _TopBar({
    required this.compact,
    required this.narrow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _CompactBrand(),

        const Spacer(),

        _MetricBadge(
          icon:
              Icons.local_fire_department_rounded,
          value: '3',
          label: narrow ? null : 'días',
          compact: compact,
        ),

        const SizedBox(width: 8),

        _MetricBadge(
          icon: Icons.auto_awesome_rounded,
          value: '1.420',
          label: narrow ? null : 'XP',
          compact: compact,
        ),
      ],
    );
  }
}

class _CompactBrand extends StatelessWidget {
  const _CompactBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: _HomeColors.gold
                  .withOpacity(0.20),
            ),
            boxShadow: [
              BoxShadow(
                color: _HomeColors.navy
                    .withOpacity(0.05),
                blurRadius: 16,
                spreadRadius: -9,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Image.asset(
            'assets/art/brand/lingoverse_emblem.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return const Icon(
                Icons.explore_rounded,
                color: _HomeColors.gold,
                size: 25,
              );
            },
          ),
        ),

        const SizedBox(width: 9),

        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Lingo',
                style: TextStyle(
                  color: _HomeColors.navy,
                  fontSize: 21,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              TextSpan(
                text: 'Verse',
                style: TextStyle(
                  color: _HomeColors.gold,
                  fontSize: 21,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String? label;
  final bool compact;

  const _MetricBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 40 : 44,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _HomeColors.navy
              .withOpacity(0.055),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _HomeColors.goldDark,
            size: compact ? 17 : 18,
          ),

          const SizedBox(width: 6),

          Text(
            value,
            style: TextStyle(
              color: _HomeColors.navy,
              fontSize: compact ? 12.5 : 13.5,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),

          if (label != null) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: TextStyle(
                color: _HomeColors.slate
                    .withOpacity(0.68),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final bool compact;

  const _WelcomeHeader({
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenido de vuelta',
          style: TextStyle(
            color: _HomeColors.slate
                .withOpacity(0.70),
            fontSize: compact ? 12 : 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          '¿Hasta dónde llegarás hoy?',
          style: TextStyle(
            color: _HomeColors.navy,
            fontSize: compact ? 25 : 29,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }
}

class _CurrentJourneyCard
    extends StatelessWidget {
  final World world;
  final String level;
  final bool compact;

  final int completedLessons;
  final double progress;

  final VoidCallback onTap;

  const _CurrentJourneyCard({
    required this.world,
    required this.level,
    required this.compact,
    required this.completedLessons,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent =
        (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        compact ? 17 : 20,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _HomeColors.navy,
            _HomeColors.navyDeep,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _HomeColors.gold
              .withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: _HomeColors.navy
                .withOpacity(0.20),
            blurRadius: 30,
            spreadRadius: -13,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -28,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.08,
                child: SizedBox(
                  width: compact ? 160 : 185,
                  height: compact ? 160 : 185,
                  child: Image.asset(
                    'assets/art/brand/lingoverse_emblem.png',
                    fit: BoxFit.contain,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'TU RUTA ACTUAL',
                          style: TextStyle(
                            color: _HomeColors.goldLight,
                            fontSize:
                                compact ? 9.3 : 10,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8,
                          ),
                        ),

                        const Spacer(),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.08),
                            borderRadius:
                                BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white
                                  .withOpacity(0.10),
                            ),
                          ),
                          child: Text(
                            level,
                            style: const TextStyle(
                              color: _HomeColors.goldLight,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: compact ? 12 : 14,
                    ),

                    Text(
                      world.language,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            compact ? 25 : 29,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '${world.city} · ${world.country}',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(0.60),
                        fontSize:
                            compact ? 11.8 : 12.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(
                      height: compact ? 17 : 20,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _ProgressBar(
                            value: progress,
                            dark: true,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          '$percent%',
                          style: const TextStyle(
                            color: _HomeColors.goldLight,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Text(
                      '$completedLessons de ${world.lessons.length} lecciones completadas',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(0.46),
                        fontSize:
                            compact ? 10 : 10.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(
                      height: compact ? 15 : 18,
                    ),

                    _ContinueButton(
                      compact: compact,
                      onTap: onTap,
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: compact ? 12 : 16,
              ),

              SizedBox(
                width: compact ? 105 : 124,
                height: compact ? 128 : 145,
                child: Image.asset(
                  world.image,
                  fit: BoxFit.contain,
                  filterQuality:
                      FilterQuality.high,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ],
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
    return SizedBox(
      height: compact ? 45 : 49,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(15),
          child: Ink(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  _HomeColors.goldLight,
                  _HomeColors.gold,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  'Continuar',
                  style: TextStyle(
                    color:
                        _HomeColors.navyDeep,
                    fontSize:
                        compact ? 13.5 : 14.5,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(width: 8),

                const Icon(
                  Icons.arrow_forward_rounded,
                  color:
                      _HomeColors.navyDeep,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _HomeColors.navy,
            fontSize: 21,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.55,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          subtitle,
          style: TextStyle(
            color: _HomeColors.slate
                .withOpacity(0.66),
            fontSize: 11.8,
            height: 1.3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _WorldCard extends StatelessWidget {
  final World world;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _WorldCard({
    required this.world,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(24),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: compact ? 138 : 150,
          padding: EdgeInsets.all(
            compact ? 11 : 13,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFFFCF5)
                : Colors.white.withOpacity(0.72),
            borderRadius:
                BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? _HomeColors.gold
                  : _HomeColors.navy
                      .withOpacity(0.055),
              width: selected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? _HomeColors.gold
                        .withOpacity(0.11)
                    : _HomeColors.navy
                        .withOpacity(0.045),
                blurRadius: 22,
                spreadRadius: -12,
                offset: const Offset(0, 13),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _HomeColors.cream
                        .withOpacity(0.78),
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(7),
                  child: Image.asset(
                    world.image,
                    fit: BoxFit.contain,
                    filterQuality:
                        FilterQuality.high,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      world.language,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _HomeColors.navy,
                        fontSize:
                            compact ? 14.5 : 15.5,
                        height: 1,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  if (selected)
                    Container(
                      width: 18,
                      height: 18,
                      decoration:
                          const BoxDecoration(
                        color:
                            _HomeColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 12,
                        color:
                            _HomeColors.navyDeep,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 5),

              Text(
                world.city,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color: _HomeColors.slate
                      .withOpacity(0.65),
                  fontSize:
                      compact ? 10.8 : 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextLessonCard
    extends StatelessWidget {
  final World world;
  final String level;
  final String lesson;

  final int completedLessons;
  final int totalLessons;

  final bool compact;
  final VoidCallback onTap;

  const _NextLessonCard({
    required this.world,
    required this.level,
    required this.lesson,
    required this.completedLessons,
    required this.totalLessons,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lessonNumber =
        math.min(
      completedLessons + 1,
      math.max(totalLessons, 1),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(27),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(27),
        child: Ink(
          padding: EdgeInsets.fromLTRB(
            compact ? 17 : 20,
            compact ? 16 : 19,
            compact ? 10 : 12,
            compact ? 16 : 19,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.76),
            borderRadius:
                BorderRadius.circular(27),
            border: Border.all(
              color: _HomeColors.navy
                  .withOpacity(0.055),
            ),
            boxShadow: [
              BoxShadow(
                color: _HomeColors.navy
                    .withOpacity(0.055),
                blurRadius: 26,
                spreadRadius: -14,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LECCIÓN ${lessonNumber.toString().padLeft(2, '0')} · $level',
                      style: TextStyle(
                        color: _HomeColors.goldDark,
                        fontSize:
                            compact ? 9.3 : 10,
                        height: 1,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),

                    SizedBox(
                      height: compact ? 8 : 10,
                    ),

                    Text(
                      lesson,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _HomeColors.navy,
                        fontSize:
                            compact ? 18 : 20,
                        height: 1.08,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing: -0.45,
                      ),
                    ),

                    SizedBox(
                      height: compact ? 8 : 10,
                    ),

                    Row(
                      children: [
                        Text(
                          'Empezar lección',
                          style: TextStyle(
                            color: _HomeColors.slate
                                .withOpacity(0.66),
                            fontSize:
                                compact ? 11 : 11.8,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(width: 7),

                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color:
                              _HomeColors.goldDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: compact ? 8 : 12,
              ),

              SizedBox(
                width: compact ? 98 : 112,
                height: compact ? 105 : 118,
                child: Image.asset(
                  'assets/art/mascot/mascota_estudiando_laptop.png',
                  fit: BoxFit.contain,
                  filterQuality:
                      FilterQuality.high,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Image.asset(
                      'assets/art/mascot/mascota_default.png',
                      fit: BoxFit.contain,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityOverview
    extends StatelessWidget {
  final int completedLessons;
  final int totalLessons;
  final bool compact;

  const _ActivityOverview({
    required this.completedLessons,
    required this.totalLessons,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 18,
        vertical: compact ? 15 : 17,
      ),
      decoration: BoxDecoration(
        color: _HomeColors.cream
            .withOpacity(0.78),
        borderRadius:
            BorderRadius.circular(23),
        border: Border.all(
          color: _HomeColors.gold
              .withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OverviewItem(
              icon:
                  Icons.check_circle_outline_rounded,
              value: '$completedLessons',
              label: 'Completadas',
              compact: compact,
            ),
          ),

          const _VerticalDivider(),

          Expanded(
            child: _OverviewItem(
              icon: Icons.route_rounded,
              value:
                  '${math.max(totalLessons - completedLessons, 0)}',
              label: 'Por descubrir',
              compact: compact,
            ),
          ),

          const _VerticalDivider(),

          Expanded(
            child: _OverviewItem(
              icon:
                  Icons.local_fire_department_outlined,
              value: '3',
              label: 'Días de racha',
              compact: compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool compact;

  const _OverviewItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: _HomeColors.goldDark,
          size: compact ? 19 : 21,
        ),

        const SizedBox(height: 7),

        Text(
          value,
          style: TextStyle(
            color: _HomeColors.navy,
            fontSize: compact ? 16 : 18,
            height: 1,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _HomeColors.slate
                .withOpacity(0.58),
            fontSize: compact ? 9.2 : 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider
    extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: 1,
      color: _HomeColors.navy
          .withOpacity(0.06),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final bool dark;

  const _ProgressBar({
    required this.value,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue =
        value.clamp(0.0, 1.0);

    return Container(
      height: 7,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withOpacity(0.11)
            : _HomeColors.navy.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        widthFactor: safeValue,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                _HomeColors.goldLight,
                _HomeColors.gold,
              ],
            ),
            borderRadius:
                BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _HomeDecorationPainter
    extends CustomPainter {
  const _HomeDecorationPainter();

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _HomeColors.gold
          .withOpacity(0.08);

    final route = Path()
      ..moveTo(
        -30,
        size.height * 0.11,
      )
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.04,
        size.width * 0.72,
        size.height * 0.05,
        size.width + 30,
        size.height * 0.13,
      );

    canvas.drawPath(
      route,
      routePaint,
    );

    final compassPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _HomeColors.navy
          .withOpacity(0.018);

    final center = Offset(
      size.width * 0.92,
      size.height * 0.77,
    );

    final radius =
        math.min(
          size.width,
          size.height,
        ) *
        0.11;

    canvas.drawCircle(
      center,
      radius,
      compassPaint,
    );

    canvas.drawCircle(
      center,
      radius * 0.60,
      compassPaint,
    );

    for (int i = 0; i < 8; i++) {
      final angle =
          (math.pi * 2 / 8) * i;

      canvas.drawLine(
        Offset(
          center.dx +
              math.cos(angle) *
                  radius *
                  0.20,
          center.dy +
              math.sin(angle) *
                  radius *
                  0.20,
        ),
        Offset(
          center.dx +
              math.cos(angle) *
                  radius,
          center.dy +
              math.sin(angle) *
                  radius,
        ),
        compassPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _HomeDecorationPainter
        oldDelegate,
  ) {
    return false;
  }
}

abstract final class _HomeColors {
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

  static const Color goldDark =
      Color(0xFFA97320);

  static const Color cream =
      Color(0xFFF4EDE2);

  static const Color ivory =
      Color(0xFFFAF7F1);
}