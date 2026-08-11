import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/data/worlds_data.dart';
import '../../../../core/models/world.dart';

class WorldsPage extends StatefulWidget {
  final World selected;
  final String level;
  final void Function(World, String) onSelect;

  const WorldsPage({
    super.key,
    required this.selected,
    required this.level,
    required this.onSelect,
  });

  @override
  State<WorldsPage> createState() => _WorldsPageState();
}

class _WorldsPageState extends State<WorldsPage> {
  late String level;

  static const _levels = [
    'A1',
    'A2',
    'B1',
    'B2',
    'C1',
  ];

  @override
  void initState() {
    super.initState();
    level = widget.level;
  }

  @override
  void didUpdateWidget(
    covariant WorldsPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.level != widget.level) {
      level = widget.level;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final width = media.size.width;
    final height = media.size.height;

    final compact = height < 820;
    final narrow = width < 370;
    final tablet = width >= 700;

    return Stack(
      children: [
        const Positioned.fill(
          child: _WorldsBackground(),
        ),

        const Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _WorldsBackgroundPainter(),
            ),
          ),
        ),

        SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              tablet
                  ? 28
                  : narrow
                      ? 14
                      : 18,
              compact ? 10 : 14,
              tablet
                  ? 28
                  : narrow
                      ? 14
                      : 18,
              media.padding.bottom + 128,
            ),
            children: [
              const _WorldsTopBar(),

              SizedBox(
                height: compact ? 22 : 28,
              ),

              _IntroHeader(
                compact: compact,
              ),

              SizedBox(
                height: compact ? 20 : 24,
              ),

              _LevelSelector(
                selected: level,
                compact: compact,
                onChanged: (value) {
                  setState(() {
                    level = value;
                  });
                },
              ),

              SizedBox(
                height: compact ? 24 : 30,
              ),

              _SectionHeader(
                count: worlds.length,
              ),

              const SizedBox(height: 14),

              if (tablet)
                _WorldGrid(
                  selected: widget.selected,
                  level: level,
                  compact: compact,
                  onSelect: widget.onSelect,
                )
              else
                ...worlds.map(
                  (world) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                      ),
                      child: _WorldDestinationCard(
                        world: world,
                        level: level,
                        selected:
                            world.id ==
                                widget.selected.id,
                        compact: compact,
                        onTap: () {
                          widget.onSelect(
                            world,
                            level,
                          );
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorldsBackground extends StatelessWidget {
  const _WorldsBackground();

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
            Color(0xFFF2E8DA),
          ],
          stops: [
            0,
            0.60,
            1,
          ],
        ),
      ),
    );
  }
}

class _WorldsTopBar extends StatelessWidget {
  const _WorldsTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _CompactBrand(),

        const Spacer(),

        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _WorldColors.navy.withOpacity(0.055),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.explore_outlined,
                color: _WorldColors.goldDark,
                size: 18,
              ),

              const SizedBox(width: 7),

              Text(
                '${worlds.length} mundos',
                style: const TextStyle(
                  color: _WorldColors.navy,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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
            color: Colors.white.withOpacity(0.84),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _WorldColors.gold.withOpacity(0.20),
            ),
            boxShadow: [
              BoxShadow(
                color: _WorldColors.navy.withOpacity(0.05),
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
                color: _WorldColors.gold,
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
                  color: _WorldColors.navy,
                  fontSize: 21,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              TextSpan(
                text: 'Verse',
                style: TextStyle(
                  color: _WorldColors.gold,
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

class _IntroHeader extends StatelessWidget {
  final bool compact;

  const _IntroHeader({
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EL MUNDO ES TUYO',
          style: TextStyle(
            color: _WorldColors.goldDark,
            fontSize: compact ? 9.5 : 10.3,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),

        SizedBox(
          height: compact ? 9 : 11,
        ),

        Text(
          'Elige tu próxima\naventura.',
          style: TextStyle(
            color: _WorldColors.navy,
            fontSize: compact ? 31 : 36,
            height: 0.98,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.1,
          ),
        ),

        SizedBox(
          height: compact ? 10 : 12,
        ),

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          child: Text(
            'Cada idioma tiene su propio recorrido, cultura, desafíos y formas de avanzar.',
            style: TextStyle(
              color: _WorldColors.slate.withOpacity(0.72),
              fontSize: compact ? 13 : 14.2,
              height: 1.42,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelSelector extends StatelessWidget {
  final String selected;
  final bool compact;
  final ValueChanged<String> onChanged;

  const _LevelSelector({
    required this.selected,
    required this.compact,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const levels = [
      'A1',
      'A2',
      'B1',
      'B2',
      'C1',
    ];

    return Container(
      padding: EdgeInsets.all(
        compact ? 7 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _WorldColors.navy.withOpacity(0.055),
        ),
        boxShadow: [
          BoxShadow(
            color: _WorldColors.navy.withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: -12,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: levels.map(
          (item) {
            final active =
                item == selected;

            return Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      onChanged(item);
                    },
                    borderRadius:
                        BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 220,
                      ),
                      curve: Curves.easeOutCubic,
                      height: compact ? 43 : 47,
                      decoration: BoxDecoration(
                        color: active
                            ? _WorldColors.navy
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(16),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: _WorldColors.navy
                                      .withOpacity(0.17),
                                  blurRadius: 16,
                                  spreadRadius: -8,
                                  offset:
                                      const Offset(0, 9),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          item,
                          style: TextStyle(
                            color: active
                                ? _WorldColors.goldLight
                                : _WorldColors.slate
                                    .withOpacity(0.75),
                            fontSize:
                                compact ? 12.5 : 13.3,
                            fontWeight: active
                                ? FontWeight.w800
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final int count;

  const _SectionHeader({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Destinos disponibles',
                style: TextStyle(
                  color: _WorldColors.navy,
                  fontSize: 21,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Selecciona un mundo para comenzar.',
                style: TextStyle(
                  color: _WorldColors.slate
                      .withOpacity(0.62),
                  fontSize: 11.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _WorldColors.gold.withOpacity(0.09),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: _WorldColors.gold.withOpacity(0.16),
            ),
          ),
          child: Text(
            '$count destinos',
            style: const TextStyle(
              color: _WorldColors.goldDark,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _WorldGrid extends StatelessWidget {
  final World selected;
  final String level;
  final bool compact;

  final void Function(
    World,
    String,
  ) onSelect;

  const _WorldGrid({
    required this.selected,
    required this.level,
    required this.compact,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.sizeOf(context).width;

    final columns =
        width >= 1050 ? 3 : 2;

    return GridView.builder(
      itemCount: worlds.length,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio:
            width >= 1050 ? 1.12 : 1.18,
      ),
      itemBuilder: (
        context,
        index,
      ) {
        final world =
            worlds[index];

        return _WorldDestinationCard(
          world: world,
          level: level,
          selected:
              world.id == selected.id,
          compact: compact,
          onTap: () {
            onSelect(
              world,
              level,
            );
          },
        );
      },
    );
  }
}

class _WorldDestinationCard
    extends StatelessWidget {
  final World world;
  final String level;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _WorldDestinationCard({
    required this.world,
    required this.level,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lessonCount =
        world.lessons.length;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(28),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight:
                compact ? 226 : 250,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFFFCF5)
                : Colors.white.withOpacity(0.76),
            borderRadius:
                BorderRadius.circular(28),
            border: Border.all(
              color: selected
                  ? _WorldColors.gold
                  : _WorldColors.navy
                      .withOpacity(0.055),
              width: selected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? _WorldColors.gold
                        .withOpacity(0.10)
                    : _WorldColors.navy
                        .withOpacity(0.05),
                blurRadius: 28,
                spreadRadius: -14,
                offset:
                    const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(27),
            child: Stack(
              children: [
                Positioned(
                  right: -25,
                  top: -25,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration:
                        BoxDecoration(
                      shape: BoxShape.circle,
                      color: _WorldColors.gold
                          .withOpacity(
                        selected
                            ? 0.07
                            : 0.035,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding:
                      EdgeInsets.all(
                    compact ? 15 : 18,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 9,
                                    vertical: 6,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: selected
                                        ? _WorldColors
                                            .navy
                                        : _WorldColors
                                            .cream,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      999,
                                    ),
                                  ),
                                  child: Text(
                                    level,
                                    style:
                                        TextStyle(
                                      color: selected
                                          ? _WorldColors
                                              .goldLight
                                          : _WorldColors
                                              .goldDark,
                                      fontSize:
                                          10.3,
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                if (selected)
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration:
                                        const BoxDecoration(
                                      color:
                                          _WorldColors
                                              .gold,
                                      shape:
                                          BoxShape.circle,
                                    ),
                                    child:
                                        const Icon(
                                      Icons
                                          .check_rounded,
                                      color:
                                          _WorldColors
                                              .navyDeep,
                                      size: 17,
                                    ),
                                  ),
                              ],
                            ),

                            SizedBox(
                              height:
                                  compact
                                      ? 13
                                      : 16,
                            ),

                            Text(
                              world.language,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: TextStyle(
                                color:
                                    _WorldColors
                                        .navy,
                                fontSize:
                                    compact
                                        ? 24
                                        : 27,
                                height: 1,
                                fontWeight:
                                    FontWeight
                                        .w800,
                                letterSpacing:
                                    -0.7,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              '${world.city} · ${world.country}',
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: TextStyle(
                                color:
                                    _WorldColors
                                        .slate
                                        .withOpacity(
                                  0.66,
                                ),
                                fontSize:
                                    compact
                                        ? 11.2
                                        : 12,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),

                            SizedBox(
                              height:
                                  compact
                                      ? 11
                                      : 13,
                            ),

                            Text(
                              world.description,
                              maxLines: 3,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: TextStyle(
                                color:
                                    _WorldColors
                                        .slate
                                        .withOpacity(
                                  0.72,
                                ),
                                fontSize:
                                    compact
                                        ? 11.3
                                        : 12.2,
                                height: 1.38,
                                fontWeight:
                                    FontWeight
                                        .w500,
                              ),
                            ),

                            SizedBox(
                              height:
                                  compact
                                      ? 13
                                      : 16,
                            ),

                            Row(
                              children: [
                                Icon(
                                  Icons
                                      .auto_stories_outlined,
                                  color:
                                      _WorldColors
                                          .goldDark,
                                  size: 16,
                                ),

                                const SizedBox(
                                  width: 6,
                                ),

                                Text(
                                  '$lessonCount lecciones',
                                  style:
                                      TextStyle(
                                    color:
                                        _WorldColors
                                            .slate
                                            .withOpacity(
                                      0.68,
                                    ),
                                    fontSize:
                                        10.8,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),

                                const Spacer(),

                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration:
                                      BoxDecoration(
                                    color: selected
                                        ? _WorldColors
                                            .navy
                                        : _WorldColors
                                            .gold,
                                    shape:
                                        BoxShape
                                            .circle,
                                  ),
                                  child: Icon(
                                    Icons
                                        .arrow_forward_rounded,
                                    color: selected
                                        ? _WorldColors
                                            .goldLight
                                        : _WorldColors
                                            .navyDeep,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        width:
                            compact ? 8 : 14,
                      ),

                      SizedBox(
                        width:
                            compact ? 118 : 140,
                        height:
                            compact ? 170 : 190,
                        child: Image.asset(
                          world.image,
                          fit: BoxFit.contain,
                          alignment:
                              Alignment
                                  .center,
                          filterQuality:
                              FilterQuality
                                  .high,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const SizedBox
                                .shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldsBackgroundPainter
    extends CustomPainter {
  const _WorldsBackgroundPainter();

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final route = Path()
      ..moveTo(
        -30,
        size.height * 0.13,
      )
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.05,
        size.width * 0.70,
        size.height * 0.06,
        size.width + 30,
        size.height * 0.15,
      );

    canvas.drawPath(
      route,
      Paint()
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _WorldColors.gold
            .withOpacity(0.09),
    );

    final center = Offset(
      size.width * 0.91,
      size.height * 0.80,
    );

    final radius = math.min(
          size.width,
          size.height,
        ) *
        0.11;

    final compassPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _WorldColors.navy
          .withOpacity(0.017);

    canvas.drawCircle(
      center,
      radius,
      compassPaint,
    );

    canvas.drawCircle(
      center,
      radius * 0.58,
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
                  0.22,
          center.dy +
              math.sin(angle) *
                  radius *
                  0.22,
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
    covariant _WorldsBackgroundPainter oldDelegate,
  ) {
    return false;
  }
}

abstract final class _WorldColors {
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