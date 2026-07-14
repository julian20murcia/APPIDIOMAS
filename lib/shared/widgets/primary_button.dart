import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 64,
        decoration: BoxDecoration(
          color: loading ? Brand.mintDark : Brand.mint,
          borderRadius: BorderRadius.circular(22),
          boxShadow: Brand.glowMint,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: loading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Brand.bgDeep,
                    ),
                  )
                : Row(
                    key: const ValueKey('content'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Brand.bgDeep,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(icon, color: Brand.bgDeep),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class OutlinedBrandButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const OutlinedBrandButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Brand.mint.withOpacity(.8)),
          color: Brand.bgDeep.withOpacity(.35),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Brand.mint,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
