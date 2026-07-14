import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

class LoginDots extends StatelessWidget {
  final int current;
  final int total;

  const LoginDots({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: current == i ? 22 : 9,
          height: 9,
          decoration: BoxDecoration(
            color: current == i ? Brand.mint : Brand.white.withOpacity(.18),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}
