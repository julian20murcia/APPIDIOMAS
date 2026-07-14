import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const SectionTitle({
    super.key,
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            action,
            style: const TextStyle(
              color: Brand.mint,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
