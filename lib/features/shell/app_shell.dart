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
  static const int _homeIndex = 0;
  static const int _courseIndex = 1;
  static const int _progressIndex = 2;
  static const int _profileIndex = 3;
  static const int _worldsIndex = 4;

  int index = _homeIndex;

  late World selected;
  String level = 'A1';

  @override
  void initState() {
    super.initState();

    selected = worlds.firstWhere(
      (world) => world.id == 'english',
      orElse: () => worlds.first,
    );
  }

  void _goHome() {
    setState(() => index = _homeIndex);
  }

  void _goCourseMap() {
    setState(() => index = _courseIndex);
  }

  void _goProgress() {
    setState(() => index = _progressIndex);
  }

  void _goProfile() {
    setState(() => index = _profileIndex);
  }

  void _goWorlds() {
    setState(() => index = _worldsIndex);
  }

  void _openWorld(World world) {
    setState(() {
      selected = world;
      level = world.id == 'english' ? 'A1' : level;
      index = _courseIndex;
    });
  }

  void _selectWorldAndLevel(World world, String selectedLevel) {
    setState(() {
      selected = world;
      level = selectedLevel;
      index = _courseIndex;
    });
  }

  void _handleBottomNavTap(int navIndex) {
    switch (navIndex) {
      case 0:
        _goHome();
        break;
      case 1:
        _goCourseMap();
        break;
      case 2:
        _goProgress();
        break;
      case 3:
        _goProfile();
        break;
      default:
        _goHome();
    }
  }

  int get _bottomNavIndex {
    if (index == _worldsIndex) return _courseIndex;
    return index;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        world: selected,
        level: level,
        onWorldTap: _openWorld,
        goMap: _goCourseMap,
      ),

      CourseMapPage(
        world: selected,
        level: level,
        onChangeWorld: _goWorlds,
      ),

      ProgressPage(
        world: selected,
      ),

      const ProfilePage(),

      WorldsPage(
        selected: selected,
        level: level,
        onSelect: _selectWorldAndLevel,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: index,
            children: pages,
          ),

          Positioned(
            left: 18,
            right: 18,
            bottom: MediaQuery.of(context).padding.bottom + 12,
            child: BrandBottomNav(
              index: _bottomNavIndex,
              onTap: _handleBottomNavTap,
            ),
          ),
        ],
      ),
    );
  }
}