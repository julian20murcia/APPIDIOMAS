import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/progress_bar.dart';

class MissionPanel extends StatelessWidget {
  final bool compact;

  const MissionPanel({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.68),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Brand.white.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Misiones diarias', style: TextStyle(fontSize: compact ? 18 : 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('2/3 completas', style: TextStyle(color: Brand.muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const MissionItem(title: 'Practica 10 frases', progress: '8/10', value: .8, xp: '20'),
          const MissionItem(title: 'Escucha 5 diÃ¡logos', progress: '5/5', value: 1, xp: '15', active: true),
          if (!compact) const MissionItem(title: 'Aprende 3 palabras', progress: '2/3', value: .66, xp: '10'),
          const SizedBox(height: 10),
          Container(
            height: 48,
            decoration: BoxDecoration(color: Brand.mint, borderRadius: BorderRadius.circular(16)),
            child: const Center(
              child: Text(
                'Ver todas las misiones',
                style: TextStyle(color: Brand.bgDeep, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MissionItem extends StatelessWidget {
  final String title;
  final String progress;
  final String xp;
  final double value;
  final bool active;

  const MissionItem({
    super.key,
    required this.title,
    required this.progress,
    required this.value,
    required this.xp,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: active ? Brand.navy.withOpacity(.48) : Brand.bgDeep.withOpacity(.36),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
              Text('â­ $xp', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Text(progress, style: const TextStyle(color: Brand.mint, fontSize: 12, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Expanded(child: ProgressBar(value: value)),
            ],
          ),
        ],
      ),
    );
  }
}
