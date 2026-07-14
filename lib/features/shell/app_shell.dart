import 'package:flutter/material.dart';

import '../../core/data/worlds_data.dart';
import '../../core/models/world.dart';
import '../../features/course/presentation/pages/course_map_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/worlds/presentation/pages/worlds_page.dart';
import 'brand_bottom_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  World selected = worlds.first;
  String level = 'B1';

  void openWorld(World w) {
    setState(() {
      selected = w;
      index = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        world: selected,
        level: level,
        onWorldTap: openWorld,
        goMap: () => setState(() => index = 1),
      ),
      CourseMapPage(
        world: selected,
        level: level,
        onChangeWorld: () => setState(() => index = 4),
      ),
      ProgressPage(world: selected),
      const ProfilePage(),
      WorldsPage(
        selected: selected,
        level: level,
        onSelect: (w, l) => setState(() {
          selected = w;
          level = l;
          index = 1;
        }),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: index, children: pages),
          Positioned(
            left: 18,
            right: 18,
            bottom: MediaQuery.of(context).padding.bottom + 12,
            child: BrandBottomNav(
              index: index == 4 ? 1 : index,
              onTap: (i) => setState(() => index = i),
            ),
          ),
        ],
      ),
    );
  }
}
