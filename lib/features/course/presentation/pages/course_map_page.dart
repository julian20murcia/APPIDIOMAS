import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/asset_widgets.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../../../shared/widgets/logo_mark.dart';
import '../../../../shared/widgets/metric_chip.dart';
import '../painters/city_silhouette_painter.dart';
import '../painters/game_path_painter.dart';
import '../widgets/current_world_bar.dart';
import '../widgets/final_challenge_card.dart';
import '../widgets/lesson_card.dart';
import '../widgets/lesson_node.dart';
import '../widgets/mission_panel.dart';

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
  late final AnimationController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        const LearningBackground(),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: ctrl,
            builder: (_, __) => CustomPaint(
              painter: LearningMotifPainter(t: ctrl.value),
            ),
          ),
        ),
        SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 14, 20, bottom + 108),
            children: [
              const Row(
                children: [
                  Expanded(child: LogoMark(size: 28)),
                  MetricChip(icon: 'ðŸ”¥', title: 'Racha', value: '3 dÃ­as'),
                  SizedBox(width: 10),
                  MetricChip(icon: 'ðŸ’Ž', title: 'XP', value: '1.420'),
                ],
              ),
              const SizedBox(height: 16),
              CurrentWorldBar(
                world: widget.world,
                level: widget.level,
                onChange: widget.onChangeWorld,
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: ctrl,
                builder: (_, __) {
                  return SizedBox(
                    height: 1080,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFF23023D).withOpacity(.32),
                              borderRadius: BorderRadius.circular(34),
                              border: Border.all(color: const Color(0xFF3B2369).withOpacity(.65)),
                            ),
                          ),
                        ),
                        Positioned.fill(child: CustomPaint(painter: CitySilhouettePainter(world: widget.world))),
                        Positioned.fill(child: CustomPaint(painter: GamePathPainter(progress: ctrl.value))),
                        Positioned(
                          top: 20,
                          left: 4,
                          right: 4,
                          child: Hero(
                            tag: 'world-${widget.world.id}',
                            child: Image.asset(widget.world.image, height: 235, fit: BoxFit.contain),
                          ),
                        ),
                        const Positioned(top: 250, left: 16, child: DecorImage('assets/art/decor/cloud.png', width: 90, opacity: .45)),
                        const Positioned(top: 320, right: 14, child: DecorImage('assets/art/decor/bushes.png', width: 130, opacity: .72)),
                        const Positioned(top: 440, left: 10, child: DecorImage('assets/art/decor/lamp.png', width: 62, opacity: .95)),
                        const Positioned(top: 520, right: 24, child: DecorImage('assets/art/decor/bench.png', width: 120, opacity: .9)),
                        const Positioned(top: 660, left: 22, child: DecorImage('assets/art/decor/tree.png', width: 118, opacity: .82)),
                        Positioned(top: 865, right: 24, child: FloatingAsset('assets/art/ui/chest.png', width: 145, t: ctrl.value)),
                        _lessonNode(1, const Offset(68, 280), widget.world.lessons[0], true, true),
                        _lessonNode(2, const Offset(255, 405), widget.world.lessons[1], true, true),
                        _lessonNode(3, const Offset(95, 565), widget.world.lessons[2], true, true),
                        _lessonNode(4, const Offset(255, 705), widget.world.lessons[3], true, true),
                        _lessonNode(5, const Offset(88, 845), widget.world.lessons[4], false, false),
                        _lessonNode(6, const Offset(242, 940), widget.world.lessons[5], false, false),
                        const Positioned(top: 835, left: 8, width: 215, child: MissionPanel(compact: false)),
                        const Positioned(top: 945, right: 20, width: 185, child: FinalChallengeCard()),
                      ],
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

  Widget _lessonNode(
    int num,
    Offset pos,
    String title,
    bool unlocked,
    bool cardRight,
  ) {
    final cardLeft = cardRight ? pos.dx + 72 : pos.dx - 165;
    return Stack(
      children: [
        Positioned(left: pos.dx, top: pos.dy, child: LessonNode(number: num, unlocked: unlocked)),
        Positioned(left: cardLeft, top: pos.dy - 4, width: 158, child: LessonCard(title: title, unlocked: unlocked, start: num == 1)),
      ],
    );
  }
}
