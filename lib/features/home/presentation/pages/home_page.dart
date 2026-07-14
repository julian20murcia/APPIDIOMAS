import 'package:flutter/material.dart';

import '../../../../core/data/worlds_data.dart';
import '../../../../core/models/world.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../../../shared/widgets/logo_mark.dart';
import '../../../../shared/widgets/metric_chip.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../features/course/presentation/widgets/mission_panel.dart';
import '../../../../features/progress/presentation/widgets/progress_summary.dart';
import '../widgets/compact_world_header.dart';
import '../widgets/world_mini_card.dart';

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
    final bottom = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        const LearningBackground(),
        Positioned.fill(child: CustomPaint(painter: const LearningMotifPainter(t: .4))),
        SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 18, 20, bottom + 108),
            children: [
              const Row(
                children: [
                  Expanded(child: LogoMark(size: 32)),
                  MetricChip(icon: 'ðŸ”¥', title: 'Racha', value: '3 dÃ­as'),
                  SizedBox(width: 10),
                  MetricChip(icon: 'ðŸ’Ž', title: 'XP', value: '1.420'),
                ],
              ),
              const SizedBox(height: 22),
              CompactWorldHeader(world: world, level: level, onTap: goMap),
              const SizedBox(height: 18),
              SectionTitle(title: 'Mundos disponibles', action: 'Ver todos', onAction: () {}),
              const SizedBox(height: 12),
              SizedBox(
                height: 214,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: worlds.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) => WorldMiniCard(
                    world: worlds[i],
                    active: worlds[i].id == world.id,
                    onTap: () => onWorldTap(worlds[i]),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: MissionPanel(compact: true)),
                  const SizedBox(width: 14),
                  Expanded(child: ProgressSummary(world: world)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
