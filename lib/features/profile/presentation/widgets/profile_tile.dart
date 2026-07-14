import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.68),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Brand.white.withOpacity(.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Brand.mint),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900))),
          const Icon(Icons.chevron_right_rounded, color: Brand.muted),
        ],
      ),
    );
  }
}
