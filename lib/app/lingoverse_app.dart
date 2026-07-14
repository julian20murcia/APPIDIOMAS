import 'package:flutter/material.dart';

import '../core/theme/brand.dart';
import '../features/auth/presentation/pages/login_page.dart';

class LingoVerseApp extends StatelessWidget {
  const LingoVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LingoVerse',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Brand.bgDeep,
        fontFamily: 'Arial',
      ),
      home: const LoginPage(),
    );
  }
}
