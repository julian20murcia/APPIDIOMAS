import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../../competition/presentation/widgets/competition_launcher_card.dart';
import '../../../english/data/english_level_1_data.dart';
import '../../../english/presentation/pages/english_lesson_page.dart';
import '../../../english/services/english_progress_service.dart';
import '../painters/city_silhouette_painter.dart';

class CourseMapPage extends StatefulWidget {
  final World world;
  final String level;
  final VoidCallback onChangeWorld;

  const CourseMapPage({
    super.key,
    required this.world,
    required this.level,
    required this.onChangeWorld,
  });

  @override
  State<CourseMapPage> createState() => _CourseMapPageState();
}

class _CourseMapPageState extends State<CourseMapPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final EnglishProgressService _progressService = EnglishProgressService();

  EnglishProgressSnapshot _englishProgress =
      EnglishProgressSnapshot.empty();

  bool _loadingProgress = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _loadProgress();
  }

  @override
  void didUpdateWidget(covariant CourseMapPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.world.id != widget.world.id &&
        widget.world.id == 'english') {
      _loadProgress();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    if (mounted) {
      setState(() => _loadingProgress = true);
    }

    final progress = await _progressService.load();

    if (!mounted) return;

    setState(() {
      _englishProgress = progress;
      _loadingProgress = false;
    });
  }

  List<String> get _lessons {
    if (widget.world.lessons.isEmpty) {
      return const ['Lección inicial'];
    }

    return widget.world.lessons;
  }

  int get _completedLessons {
    if (widget.world.id == 'english') {
      return _englishProgress.completedLessons;
    }

    return 0;
  }

  int get _availableLessonIndex {
    if (_lessons.isEmpty) return 0;

    if (widget.world.id == 'english') {
      return math.min(
        _englishProgress.nextLessonNumber - 1,
        _lessons.length - 1,
      );
    }

    return 0;
  }

  double get _progressValue {
    if (_lessons.isEmpty) return 0;

    return (_completedLessons / _lessons.length).clamp(0.0, 1.0);
  }

  int get _displayXp {
    if (widget.world.id == 'english') {
      return _englishProgress.totalXp;
    }

    return 0;
  }

  Future<void> _openEnglishLesson(int lessonNumber) async {
    final lesson = getEnglishLessonByNumber(lessonNumber);

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => EnglishLessonPage(
          lesson: lesson,
        ),
      ),
    );

    if (!mounted || result == null) return;

    final passed = result['passed'] == true;
    final score = (result['score'] as num?)?.toInt() ?? 0;
    final attempts = (result['attempts'] as num?)?.toInt() ?? 1;
    final xp = (result['xp'] as num?)?.toInt() ?? 0;
    final completedLesson =
        (result['lessonNumber'] as num?)?.toInt() ?? lessonNumber;

    final progress = await _progressService.saveLessonResult(
      lessonNumber: completedLesson,
      score: score,
      passed: passed,
      attempts: attempts,
      xp: xp,
    );

    if (!mounted) return;

    setState(() {
      _englishProgress = progress;
      _loadingProgress = false;
    });

    if (passed) {
      final finishedLevel =
          progress.completedLessons >= _lessons.length;

      _showProgressMessage(
        finishedLevel
            ? '¡Nivel 1 completado! Terminaste las ${_lessons.length} lecciones.'
            : '¡Lección aprobada! Se desbloqueó la lección ${progress.nextLessonNumber}.',
        success: true,
      );
    } else {
      _showProgressMessage(
        'Necesitas al menos 70 puntos para desbloquear la siguiente lección.',
        success: false,
      );
    }
  }

  void _showProgressMessage(
    String message, {
    required bool success,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Brand.bgPanel,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 96),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: success
                ? Brand.mint.withOpacity(0.55)
                : Brand.white.withOpacity(0.12),
          ),
        ),
        content: Row(
          children: [
            Icon(
              success
                  ? Icons.lock_open_rounded
                  : Icons.info_outline_rounded,
              color: success ? Brand.mint : Brand.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Brand.white,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottom = media.padding.bottom;
    final compact = media.size.height < 820;

    return Stack(
      children: [
        const LearningBackground(),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (_, __) {
              return CustomPaint(
                painter: LearningMotifPainter(
                  t: _animationController.value,
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              18,
              compact ? 12 : 16,
              18,
              bottom + 132,
            ),
            children: [
              _CourseTopBar(
                compact: compact,
                xp: _displayXp,
              ),
              SizedBox(height: compact ? 16 : 18),
              _CurrentWorldSummary(
                world: widget.world,
                level: widget.level,
                compact: compact,
                completedLessons: _completedLessons,
                totalLessons: _lessons.length,
                progressValue: _progressValue,
                loading: _loadingProgress &&
                    widget.world.id == 'english',
                onChangeWorld: widget.onChangeWorld,
              ),
              SizedBox(height: compact ? 16 : 18),
              _CourseRouteHeader(
                compact: compact,
                totalLessons: _lessons.length,
                completedLessons: _completedLessons,
                world: widget.world,
              ),
              const SizedBox(height: 12),

              if (widget.world.id == 'english') ...[
                CompetitionLauncherCard(
                  lessonNumber: math.min(
                    _completedLessons + 1,
                    _lessons.length,
                  ),
                ),
                const SizedBox(height: 14),
              ],

              AnimatedBuilder(
                animation: _animationController,
                builder: (_, __) {
                  return _CourseRoutePanel(
                    world: widget.world,
                    compact: compact,
                    progress: _animationController.value,
                    lessons: _lessons,
                    completedLessons: _completedLessons,
                    availableLessonIndex: _availableLessonIndex,
                    scores: {
                      for (final entry
                          in _englishProgress.results.entries)
                        entry.key: entry.value.score,
                    },
                    onEnglishLessonTap: _openEnglishLesson,
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

class _CourseTopBar extends StatelessWidget {
  final bool compact;
  final int xp;

  const _CourseTopBar({
    required this.compact,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniLogo(
          fontSize: compact ? 27 : 30,
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
          value: '$xp',
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
                letterSpacing: -1.3,
              ),
            ),
            TextSpan(
              text: 'Verse',
              style: TextStyle(
                color: Brand.mint,
                fontSize: fontSize,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.3,
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
      height: compact ? 44 : 48,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.58),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Brand.white.withOpacity(0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Brand.mint,
            size: compact ? 17 : 19,
          ),
          const SizedBox(width: 7),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Brand.white.withOpacity(0.58),
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Brand.white,
                  fontSize: compact ? 12.5 : 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentWorldSummary extends StatelessWidget {
  final World world;
  final String level;
  final bool compact;
  final int completedLessons;
  final int totalLessons;
  final double progressValue;
  final bool loading;
  final VoidCallback onChangeWorld;

  const _CurrentWorldSummary({
    required this.world,
    required this.level,
    required this.compact,
    required this.completedLessons,
    required this.totalLessons,
    required this.progressValue,
    required this.loading,
    required this.onChangeWorld,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progressValue * 100).round();

    return Container(
      height: compact ? 132 : 144,
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 13 : 15),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.58),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Brand.white.withOpacity(0.11),
        ),
        boxShadow: Brand.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 86 : 96,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Brand.bgDeep.withOpacity(0.35),
              borderRadius: BorderRadius.circular(22),
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
                errorBuilder: (_, __, ___) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          SizedBox(width: compact ? 13 : 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mundo actual',
                  style: TextStyle(
                    color: Brand.white.withOpacity(0.58),
                    fontSize: compact ? 12 : 12.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${world.language} · ${world.city}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Brand.white,
                    fontSize: compact ? 20 : 23,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                if (loading)
                  const LinearProgressIndicator(
                    color: Brand.mint,
                    backgroundColor: Brand.line,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _ProgressLine(
                          value: progressValue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          color: Brand.mint,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        level,
                        style: const TextStyle(
                          color: Brand.mint,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Text(
                  '$completedLessons de $totalLessons lecciones completadas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Brand.white.withOpacity(0.54),
                    fontSize: 11.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onChangeWorld,
              child: Container(
                width: compact ? 52 : 60,
                height: compact ? 52 : 60,
                decoration: BoxDecoration(
                  color: Brand.navy.withOpacity(0.78),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: Brand.mint,
                  size: 27,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseRouteHeader extends StatelessWidget {
  final bool compact;
  final int totalLessons;
  final int completedLessons;
  final World world;

  const _CourseRouteHeader({
    required this.compact,
    required this.totalLessons,
    required this.completedLessons,
    required this.world,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            world.id == 'english'
                ? 'Nivel 1 completo'
                : 'Ruta de aprendizaje',
            style: TextStyle(
              color: Brand.white,
              fontSize: compact ? 22 : 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.55,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Brand.mint.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Brand.mint.withOpacity(0.38),
            ),
          ),
          child: Text(
            '$completedLessons/$totalLessons',
            style: const TextStyle(
              color: Brand.mint,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _CourseRoutePanel extends StatelessWidget {
  final World world;
  final bool compact;
  final double progress;
  final List<String> lessons;
  final int completedLessons;
  final int availableLessonIndex;
  final Map<int, int> scores;
  final Future<void> Function(int lessonNumber) onEnglishLessonTap;

  const _CourseRoutePanel({
    required this.world,
    required this.compact,
    required this.progress,
    required this.lessons,
    required this.completedLessons,
    required this.availableLessonIndex,
    required this.scores,
    required this.onEnglishLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final count = math.max(lessons.length, 1);
    final nodeSize = compact ? 58.0 : 62.0;
    final firstTop = compact ? 262.0 : 286.0;
    final gap = compact ? 112.0 : 122.0;
    final routeHeight =
        firstTop + ((count - 1) * gap) + nodeSize + 118;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final leftNode = width * 0.09;
        final rightNode = width * 0.74;
        final cardWidth = math.min(
          width < 370 ? 158.0 : 174.0,
          width * 0.49,
        );

        final points = List.generate(count, (index) {
          final nodeX = index.isOdd ? rightNode : leftNode;
          final top = firstTop + (index * gap);

          return Offset(
            nodeX + (nodeSize / 2),
            top + (nodeSize / 2),
          );
        });

        return Container(
          height: routeHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Brand.bgPanel.withOpacity(0.34),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: Brand.line.withOpacity(0.65),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: CitySilhouettePainter(
                      world: world,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DynamicRoutePathPainter(
                      points: points,
                      progress: progress,
                      completedCount: completedLessons,
                    ),
                  ),
                ),
                Positioned(
                  top: 22,
                  left: 18,
                  right: 18,
                  child: Hero(
                    tag: 'world-${world.id}',
                    child: Image.asset(
                      world.image,
                      height: compact ? 206 : 228,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
                Positioned(
                  top: compact ? 204 : 226,
                  left: 18,
                  right: 18,
                  child: _RouteIntroCard(
                    compact: compact,
                    world: world,
                    totalLessons: lessons.length,
                  ),
                ),
                ..._buildDecorations(routeHeight),
                ...List.generate(count, (index) {
                  final lessonNumber = index + 1;
                  final rightSide = index.isOdd;
                  final nodeX = rightSide ? rightNode : leftNode;
                  final top = firstTop + (index * gap);
                  final cardX = rightSide
                      ? nodeX - cardWidth - 14
                      : nodeX + nodeSize + 12;

                  final completed = index < completedLessons;
                  final unlocked =
                      completed || index == availableLessonIndex;
                  final finalNode = index == count - 1;

                  return _lessonNode(
                    context: context,
                    number: lessonNumber,
                    nodeX: nodeX,
                    top: top,
                    title: lessons[index],
                    unlocked: unlocked,
                    completed: completed,
                    cardX: cardX,
                    cardWidth: cardWidth,
                    nodeSize: nodeSize,
                    start: index == 0,
                    finalNode: finalNode,
                    score: scores[lessonNumber],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDecorations(double routeHeight) {
    return [
      _decor(
        top: 300,
        left: 12,
        asset: 'assets/art/decor/cloud.png',
        width: 68,
        opacity: 0.25,
      ),
      _decor(
        top: 520,
        right: 18,
        asset: 'assets/art/decor/bushes.png',
        width: 88,
        opacity: 0.42,
      ),
      _decor(
        top: 780,
        left: 18,
        asset: 'assets/art/decor/lamp.png',
        width: 46,
        opacity: 0.58,
      ),
      _decor(
        top: routeHeight - 180,
        right: 22,
        asset: 'assets/art/ui/chest.png',
        width: 112,
        opacity: 0.76,
      ),
    ];
  }

  Widget _lessonNode({
    required BuildContext context,
    required int number,
    required double nodeX,
    required double top,
    required String title,
    required bool unlocked,
    required bool completed,
    required double cardX,
    required double cardWidth,
    required double nodeSize,
    required bool start,
    required bool finalNode,
    required int? score,
  }) {
    Future<void> handleTap() async {
      if (!unlocked) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Brand.bgPanel,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 96),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            content: const Text(
              'Aprueba la lección anterior con mínimo 70 puntos para desbloquear esta.',
              style: TextStyle(
                color: Brand.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
        return;
      }

      if (world.id == 'english') {
        await onEnglishLessonTap(number);
        return;
      }

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _GenericLessonSheet(
          number: number,
          title: title,
        ),
      );
    }

    return Stack(
      children: [
        Positioned(
          left: nodeX,
          top: top,
          child: _RouteNode(
            number: number,
            unlocked: unlocked,
            completed: completed,
            size: nodeSize,
            onTap: handleTap,
          ),
        ),
        Positioned(
          left: cardX,
          top: top + 4,
          width: cardWidth,
          child: _RouteLessonCard(
            number: number,
            title: title,
            start: start,
            unlocked: unlocked,
            completed: completed,
            finalNode: finalNode,
            score: score,
            onTap: handleTap,
          ),
        ),
      ],
    );
  }

  Widget _decor({
    required double top,
    required String asset,
    double? left,
    double? right,
    required double width,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Opacity(
        opacity: opacity,
        child: Image.asset(
          asset,
          width: width,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _RouteIntroCard extends StatelessWidget {
  final bool compact;
  final World world;
  final int totalLessons;

  const _RouteIntroCard({
    required this.compact,
    required this.world,
    required this.totalLessons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 13 : 15),
      decoration: BoxDecoration(
        color: Brand.bgDeep.withOpacity(0.58),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Brand.white.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 42 : 46,
            height: compact ? 42 : 46,
            decoration: BoxDecoration(
              color: Brand.mint.withOpacity(0.13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Brand.mint.withOpacity(0.32),
              ),
            ),
            child: const Icon(
              Icons.route_rounded,
              color: Brand.mint,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  world.id == 'english'
                      ? 'Ruta oficial de Inglés Nivel 1'
                      : world.safeThemeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Brand.white,
                    fontSize: compact ? 15.5 : 16.8,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Aprueba con mínimo 70 puntos para avanzar por las $totalLessons lecciones.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Brand.white.withOpacity(0.58),
                    fontSize: compact ? 11.8 : 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteNode extends StatelessWidget {
  final int number;
  final bool unlocked;
  final bool completed;
  final double size;
  final VoidCallback onTap;

  const _RouteNode({
    required this.number,
    required this.unlocked,
    required this.completed,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? Brand.mint
        : unlocked
            ? Brand.cyan
            : Brand.bgPanel.withOpacity(0.94);

    final textColor =
        unlocked ? Brand.bgDeep : Brand.white.withOpacity(0.45);

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Brand.white.withOpacity(
                unlocked ? 0.90 : 0.14,
              ),
              width: unlocked ? 3.4 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: unlocked
                    ? color.withOpacity(0.26)
                    : Colors.black.withOpacity(0.20),
                blurRadius: 20,
                spreadRadius: -8,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Center(
            child: completed
                ? Icon(
                    Icons.check_rounded,
                    color: textColor,
                    size: size * 0.46,
                  )
                : unlocked
                    ? Text(
                        '$number',
                        style: TextStyle(
                          color: textColor,
                          fontSize:
                              number >= 10 ? size * 0.31 : size * 0.39,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      )
                    : Icon(
                        Icons.lock_rounded,
                        color: textColor,
                        size: size * 0.38,
                      ),
          ),
        ),
      ),
    );
  }
}

class _RouteLessonCard extends StatelessWidget {
  final int number;
  final String title;
  final bool start;
  final bool unlocked;
  final bool completed;
  final bool finalNode;
  final int? score;
  final VoidCallback onTap;

  const _RouteLessonCard({
    required this.number,
    required this.title,
    required this.start,
    required this.unlocked,
    required this.completed,
    required this.finalNode,
    required this.score,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final eyebrow = finalNode
        ? 'Lección final'
        : start
            ? 'Empieza aquí'
            : 'Lección ${number.toString().padLeft(2, '0')}';

    final status = completed
        ? 'Completado · ${score ?? 0} pts'
        : unlocked
            ? 'Disponible'
            : 'Bloqueado';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
          decoration: BoxDecoration(
            color: Brand.bgPanel.withOpacity(
              unlocked ? 0.82 : 0.50,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: unlocked
                  ? Brand.mint.withOpacity(0.48)
                  : Brand.white.withOpacity(0.10),
            ),
            boxShadow: Brand.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: unlocked
                      ? Brand.mint
                      : Brand.white.withOpacity(0.42),
                  fontSize: 11.3,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: unlocked
                      ? Brand.white
                      : Brand.white.withOpacity(0.54),
                  fontSize: 14.5,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : unlocked
                            ? Icons.play_circle_fill_rounded
                            : Icons.lock_rounded,
                    color: unlocked
                        ? Brand.mint
                        : Brand.white.withOpacity(0.42),
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unlocked
                            ? Brand.mint
                            : Brand.white.withOpacity(0.44),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
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

class _GenericLessonSheet extends StatelessWidget {
  final int number;
  final String title;

  const _GenericLessonSheet({
    required this.number,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Brand.bgPanel,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Brand.white.withOpacity(0.12),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lección $number',
              style: const TextStyle(
                color: Brand.mint,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Brand.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Este mundo todavía no tiene actividades detalladas conectadas.',
              style: TextStyle(
                color: Brand.white.withOpacity(0.65),
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicRoutePathPainter extends CustomPainter {
  final List<Offset> points;
  final double progress;
  final int completedCount;

  const _DynamicRoutePathPainter({
    required this.points,
    required this.progress,
    required this.completedCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final middleY = (a.dy + b.dy) / 2;
      final pull = i.isEven ? 36.0 : -36.0;

      path.cubicTo(
        a.dx + pull,
        middleY,
        b.dx - pull,
        middleY,
        b.dx,
        b.dy,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 39
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Brand.purple.withOpacity(0.17)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          13,
        ),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 31
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Brand.purple.withOpacity(0.50),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Brand.bgPanel.withOpacity(0.84),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Brand.mint.withOpacity(0.42),
    );

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final completion =
        (completedCount / points.length).clamp(0.0, 1.0);

    if (completion > 0) {
      final completedPath = metric.extractPath(
        0,
        metric.length * completion,
      );

      canvas.drawPath(
        completedPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round
          ..color = Brand.mint.withOpacity(0.95),
      );
    }

    final dotPaint = Paint()
      ..color = Brand.cyan.withOpacity(0.70);

    for (int i = 0; i < 14; i++) {
      final factor = (progress + i / 14) % 1;
      final tangent = metric.getTangentForOffset(
        metric.length * factor,
      );

      if (tangent != null) {
        canvas.drawCircle(
          tangent.position,
          2,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant _DynamicRoutePathPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress ||
        oldDelegate.completedCount != completedCount ||
        oldDelegate.points.length != points.length;
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
        widthFactor: value.clamp(0.0, 1.0),
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
