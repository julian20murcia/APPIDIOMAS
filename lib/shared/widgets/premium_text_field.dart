import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class PremiumTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData icon;
  final String hint;
  final IconData? trailing;
  final bool obscureText;
  final TextInputType? keyboardType;
  final VoidCallback? onTrailingTap;

  const PremiumTextField({
    super.key,
    this.controller,
    required this.icon,
    required this.hint,
    this.trailing,
    this.obscureText = false,
    this.keyboardType,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Brand.white.withOpacity(.13)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        cursorColor: Brand.mint,
        style: const TextStyle(
          color: Brand.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Brand.muted),
          suffixIcon: trailing == null
              ? null
              : IconButton(
                  onPressed: onTrailingTap,
                  icon: Icon(trailing, color: Brand.muted),
                ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Brand.white.withOpacity(.46),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          contentPadding: const EdgeInsets.only(top: 18),
        ),
      ),
    );
  }
}
