import 'package:flutter/material.dart';

import '../../../../core/data/worlds_data.dart';
import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../../../shared/widgets/logo_mark.dart';
import '../widgets/level_chip.dart';
import '../widgets/world_large_card.dart';

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

  @override
  void initState() {
    super.initState();
    level = widget.level;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        const LearningBackground(),
        Positioned.fill(child: CustomPaint(painter: const LearningMotifPainter(t: .8))),
        SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 108),
            children: [
              const LogoMark(size: 32),
              const SizedBox(height: 18),
              const Text(
                'Elige tu mundo',
                style: TextStyle(fontSize: 34, height: 1, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cada idioma tiene una ruta, misiones y recompensas diferentes.',
                style: TextStyle(color: Brand.muted, fontSize: 15, height: 1.35),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: ['A1', 'A2', 'B1', 'B2', 'C1']
                    .map(
                      (l) => LevelChip(
                        label: l,
                        active: level == l,
                        onTap: () => setState(() => level = l),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 22),
              ...worlds.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: WorldLargeCard(
                    world: w,
                    active: w.id == widget.selected.id,
                    onTap: () => widget.onSelect(w, level),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
