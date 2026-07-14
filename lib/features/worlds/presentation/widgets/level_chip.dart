import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

class LevelChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const LevelChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: active ? Brand.mint : Brand.bgPanel.withOpacity(.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: active ? Brand.mint : Brand.white.withOpacity(.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Brand.bgDeep : Brand.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
