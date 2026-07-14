import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../../../shared/widgets/logo_mark.dart';
import '../widgets/profile_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        const LearningBackground(),
        Positioned.fill(child: CustomPaint(painter: const LearningMotifPainter(t: .6))),
        SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 22, 20, bottom + 108),
            children: [
              const LogoMark(size: 30),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Brand.mint,
                    boxShadow: Brand.glowMint,
                  ),
                  child: const Center(
                    child: Text(
                      'S',
                      style: TextStyle(fontSize: 46, color: Brand.bgDeep, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Santiago', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const Text('Explorador de idiomas', textAlign: TextAlign.center, style: TextStyle(color: Brand.muted, fontWeight: FontWeight.w700)),
              const SizedBox(height: 22),
              const ProfileTile(icon: Icons.person_outline_rounded, title: 'Editar perfil'),
              const ProfileTile(icon: Icons.notifications_none_rounded, title: 'Recordatorios'),
              const ProfileTile(icon: Icons.workspace_premium_outlined, title: 'Logros'),
              const ProfileTile(icon: Icons.settings_outlined, title: 'ConfiguraciÃ³n'),
            ],
          ),
        ),
      ],
    );
  }
}
