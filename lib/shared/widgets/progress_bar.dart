import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class ProgressBar extends StatelessWidget {
  final double value;

  const ProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 9,
        backgroundColor: Brand.white.withOpacity(.13),
        valueColor: const AlwaysStoppedAnimation(Brand.mint),
      ),
    );
  }
}
