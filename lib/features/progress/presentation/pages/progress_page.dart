import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../../../shared/widgets/logo_mark.dart';
import '../../../../features/course/presentation/widgets/mission_panel.dart';
import '../widgets/progress_summary.dart';

class ProgressPage extends StatelessWidget {
  final World world;

  const ProgressPage({super.key, required this.world});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        const LearningBackground(),
        Positioned.fill(child: CustomPaint(painter: const LearningMotifPainter(t: .2))),
        SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 22, 20, bottom + 108),
            children: [
              const LogoMark(size: 30),
              const SizedBox(height: 22),
              const Text('Tu avance', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Resumen quemado mientras conectamos datos reales.', style: TextStyle(color: Brand.muted)),
              const SizedBox(height: 18),
              ProgressSummary(world: world, large: true),
              const SizedBox(height: 18),
              const MissionPanel(compact: false),
            ],
          ),
        ),
      ],
    );
  }
}
