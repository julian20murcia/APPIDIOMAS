import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class MetricChip extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const MetricChip({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Brand.white.withOpacity(.08)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Brand.muted, fontSize: 11),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
