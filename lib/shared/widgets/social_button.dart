import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class SocialButton extends StatelessWidget {
  final String label;

  const SocialButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Brand.bgPanel.withOpacity(.6),
        border: Border.all(color: Brand.white.withOpacity(.10)),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
