import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class DividerLabel extends StatelessWidget {
  final String text;

  const DividerLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Brand.white.withOpacity(.14))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: TextStyle(
              color: Brand.white.withOpacity(.48),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Divider(color: Brand.white.withOpacity(.14))),
      ],
    );
  }
}
