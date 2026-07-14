# LingoVerse - Refactor completo desde main.dart gigante a estructura profesional
# Ejecutar desde la raiz del proyecto Flutter: C:\Users\SANTIAGO\Desktop\EvolCorp\appidiomas

$ErrorActionPreference = "Stop"

Write-Host "\n=== LingoVerse Full Refactor ===" -ForegroundColor Cyan
Write-Host "Creando estructura profesional por features, core y shared..." -ForegroundColor Cyan

if (!(Test-Path "lib")) {
  throw "No se encontro la carpeta lib. Ejecuta este script desde la raiz del proyecto Flutter."
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
if (Test-Path "lib/main.dart") {
  Copy-Item "lib/main.dart" "lib/main_backup_$timestamp.dart" -Force
  Write-Host "Backup creado: lib/main_backup_$timestamp.dart" -ForegroundColor Yellow
}

$dirs = @(
  "lib/app",
  "lib/core/theme",
  "lib/core/models",
  "lib/core/data",
  "lib/features/auth/presentation/pages",
  "lib/features/auth/presentation/widgets",
  "lib/features/shell",
  "lib/features/home/presentation/pages",
  "lib/features/home/presentation/widgets",
  "lib/features/worlds/presentation/pages",
  "lib/features/worlds/presentation/widgets",
  "lib/features/course/presentation/pages",
  "lib/features/course/presentation/widgets",
  "lib/features/progress/presentation/pages",
  "lib/features/profile/presentation/pages",
  "lib/shared/widgets",
  "lib/shared/painters"
)

foreach ($dir in $dirs) {
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

function Write-DartFile($path, $content) {
  $parent = Split-Path $path -Parent
  if (!(Test-Path $parent)) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }
  Set-Content -Path $path -Value $content -Encoding UTF8
  Write-Host "OK $path" -ForegroundColor Green
}

Write-DartFile "lib/main.dart" @'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/lingoverse_app.dart';
import 'core/theme/brand.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Brand.bgDeep,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const LingoVerseApp());
}
'@

Write-DartFile "lib/app/lingoverse_app.dart" @'
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
'@

Write-DartFile "lib/core/theme/brand.dart" @'
import 'package:flutter/material.dart';

class Brand {
  static const bgDeep = Color(0xFF13023D);
  static const bgPanel = Color(0xFF23023D);
  static const purple = Color(0xFF6000C7);
  static const cyan = Color(0xFF00BAFF);
  static const mint = Color(0xFF00FFC4);
  static const mintDark = Color(0xFF00CC9C);
  static const navy = Color(0xFF05058C);
  static const white = Color(0xFFFFFFFF);
  static const muted = Color(0xFFBDAFE2);
  static const line = Color(0xFF3B2369);
  static const yellow = Color(0xFFFFC94D);

  static List<BoxShadow> get glowMint => [
        BoxShadow(
          color: mint.withOpacity(.26),
          blurRadius: 26,
          spreadRadius: -6,
        ),
        BoxShadow(
          color: cyan.withOpacity(.12),
          blurRadius: 40,
          spreadRadius: -8,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(.33),
          blurRadius: 30,
          offset: const Offset(0, 18),
        ),
      ];
}
'@

Write-DartFile "lib/core/models/world.dart" @'
class World {
  final String id;
  final String language;
  final String city;
  final String flag;
  final String hello;
  final String image;
  final List<String> lessons;

  const World({
    required this.id,
    required this.language,
    required this.city,
    required this.flag,
    required this.hello,
    required this.image,
    required this.lessons,
  });
}
'@

Write-DartFile "lib/core/data/worlds_data.dart" @'
import '../models/world.dart';

const worlds = <World>[
  World(
    id: 'english',
    language: 'Inglés',
    city: 'Londres',
    flag: '🇬🇧',
    hello: 'Hello!',
    image: 'assets/art/worlds/london.png',
    lessons: [
      'Saludos y presentaciones',
      'Conversaciones básicas',
      'Preguntas y respuestas',
      'Pedir y dar direcciones',
      'En el restaurante',
      'De compras',
    ],
  ),
  World(
    id: 'italian',
    language: 'Italiano',
    city: 'Roma',
    flag: '🇮🇹',
    hello: 'Ciao!',
    image: 'assets/art/worlds/italy.png',
    lessons: [
      'Saludos en Italia',
      'Pronunciación básica',
      'En la cafetería',
      'Moverse por la ciudad',
      'En el restaurante',
      'Compras y precios',
    ],
  ),
  World(
    id: 'portuguese',
    language: 'Portugués',
    city: 'Lisboa',
    flag: '🇵🇹',
    hello: 'Olá!',
    image: 'assets/art/worlds/portugal.png',
    lessons: [
      'Frases cotidianas',
      'Escucha y repite',
      'En el tranvía',
      'Preguntar direcciones',
      'En la costa',
      'Reto Lisboa',
    ],
  ),
  World(
    id: 'french',
    language: 'Francés',
    city: 'París',
    flag: '🇫🇷',
    hello: 'Salut!',
    image: 'assets/art/worlds/france.png',
    lessons: [
      'Primeras frases',
      'Escucha francesa',
      'En el café',
      'Cómo presentarte',
      'Viajar por París',
      'Reto final',
    ],
  ),
  World(
    id: 'german',
    language: 'Alemán',
    city: 'Berlín',
    flag: '🇩🇪',
    hello: 'Hallo!',
    image: 'assets/art/worlds/germany.png',
    lessons: [
      'Saludos y sonidos',
      'Frases útiles',
      'En la estación',
      'Pedir ayuda',
      'Vida diaria',
      'Reto Berlín',
    ],
  ),
];
'@

Write-DartFile "lib/shared/widgets/learning_background.dart" @'
import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class LearningBackground extends StatelessWidget {
  const LearningBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Brand.bgDeep),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Brand.purple.withOpacity(.18),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Brand.navy.withOpacity(.28),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -60,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Brand.bgPanel.withOpacity(.95),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
'@

Write-DartFile "lib/shared/painters/learning_motif_painter.dart" @'
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class LearningMotifPainter extends CustomPainter {
  final double t;

  const LearningMotifPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Brand.white.withOpacity(.07);

    for (int i = 0; i < 7; i++) {
      final y = size.height * (.12 + i * .13) +
          math.sin(t * math.pi * 2 + i) * 12;
      final path = Path()
        ..moveTo(-30, y)
        ..quadraticBezierTo(
          size.width * .38,
          y - 35,
          size.width + 40,
          y + 10,
        );
      canvas.drawPath(path, p);
    }

    final fill = Paint()..color = Brand.mint.withOpacity(.12);
    for (int i = 0; i < 16; i++) {
      final x = (i * 73 + t * 50) % (size.width + 60) - 30;
      final y = (i * 137) % size.height;
      canvas.drawCircle(Offset(x, y), 2 + (i % 3), fill);
    }
  }

  @override
  bool shouldRepaint(covariant LearningMotifPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
'@

Write-DartFile "lib/shared/widgets/logo_mark.dart" @'
import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class LogoMark extends StatelessWidget {
  final bool center;
  final double size;

  const LogoMark({
    super.key,
    this.center = false,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: center ? Alignment.center : Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            letterSpacing: -2.4,
            height: 1,
          ),
          children: const [
            TextSpan(text: 'Lingo', style: TextStyle(color: Brand.white)),
            TextSpan(text: 'Verse', style: TextStyle(color: Brand.mint)),
          ],
        ),
      ),
    );
  }
}
'@

Write-DartFile "lib/shared/widgets/bubble_asset.dart" @'
import 'package:flutter/material.dart';

class BubbleAsset extends StatelessWidget {
  final String asset;
  final double width;
  final double angle;

  const BubbleAsset(
    this.asset, {
    super.key,
    required this.width,
    this.angle = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Image.asset(asset, width: width),
    );
  }
}
'@

Write-DartFile "lib/shared/widgets/divider_label.dart" @'
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
'@

Write-DartFile "lib/shared/widgets/premium_text_field.dart" @'
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
'@

Write-DartFile "lib/shared/widgets/primary_button.dart" @'
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
'@

Write-DartFile "lib/shared/widgets/social_button.dart" @'
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
'@

Write-DartFile "lib/shared/widgets/metric_chip.dart" @'
import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class MetricChip extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const MetricChip({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Brand.white.withOpacity(.08)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Brand.muted, fontSize: 11),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
'@

Write-DartFile "lib/shared/widgets/progress_bar.dart" @'
import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class ProgressBar extends StatelessWidget {
  final double value;

  const ProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 9,
        backgroundColor: Brand.white.withOpacity(.13),
        valueColor: const AlwaysStoppedAnimation(Brand.mint),
      ),
    );
  }
}
'@

Write-DartFile "lib/shared/widgets/section_title.dart" @'
import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const SectionTitle({
    super.key,
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            action,
            style: const TextStyle(
              color: Brand.mint,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
'@

Write-DartFile "lib/shared/widgets/asset_widgets.dart" @'
import 'dart:math' as math;

import 'package:flutter/material.dart';

class DecorImage extends StatelessWidget {
  final String asset;
  final double width;
  final double opacity;

  const DecorImage(
    this.asset, {
    super.key,
    required this.width,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Image.asset(asset, width: width),
    );
  }
}

class FloatingAsset extends StatelessWidget {
  final String asset;
  final double width;
  final double t;

  const FloatingAsset(
    this.asset, {
    super.key,
    required this.width,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, math.sin(t * math.pi * 2) * 8),
      child: Image.asset(asset, width: width),
    );
  }
}
'@

Write-DartFile "lib/features/auth/presentation/widgets/login_header.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/logo_mark.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LogoMark(center: true, size: 54),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 18,
              color: Brand.muted,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(text: 'Aprende jugando, '),
              TextSpan(
                text: 'explora el mundo',
                style: TextStyle(color: Brand.mint),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
'@

Write-DartFile "lib/features/auth/presentation/widgets/login_dots.dart" @'
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
'@

Write-DartFile "lib/features/auth/presentation/widgets/login_world_card.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/painters/mini_route_painter.dart';

class LoginWorldCard extends StatelessWidget {
  final World world;
  final bool active;

  const LoginWorldCard({
    super.key,
    required this.world,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: EdgeInsets.symmetric(
        horizontal: active ? 2 : 8,
        vertical: active ? 0 : 24,
      ),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(active ? .55 : .35),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: active ? Brand.purple.withOpacity(.9) : Brand.white.withOpacity(.10),
          width: active ? 2 : 1,
        ),
        boxShadow: active ? Brand.glowMint : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: CustomPaint(painter: MiniRoutePainter(active: active))),
          Positioned(
            top: 18,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: Brand.bgPanel.withOpacity(.78),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Brand.white.withOpacity(.08)),
                ),
                child: Text(
                  '${world.language} ${world.flag}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 55, 10, 8),
              child: Hero(
                tag: 'world-${world.id}',
                child: Image.asset(world.image, fit: BoxFit.contain),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
'@

Write-DartFile "lib/shared/painters/mini_route_painter.dart" @'
import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class MiniRoutePainter extends CustomPainter {
  final bool active;

  const MiniRoutePainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 3 : 2
      ..strokeCap = StrokeCap.round
      ..color = (active ? Brand.mint : Brand.white).withOpacity(active ? .55 : .18);

    final path = Path()
      ..moveTo(size.width * .12, size.height * .73)
      ..cubicTo(
        size.width * .32,
        size.height * .45,
        size.width * .62,
        size.height * .86,
        size.width * .82,
        size.height * .55,
      );

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant MiniRoutePainter oldDelegate) {
    return oldDelegate.active != active;
  }
}
'@

Write-DartFile "lib/features/auth/presentation/widgets/login_world_carousel.dart" @'
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/data/worlds_data.dart';
import '../../../../shared/widgets/bubble_asset.dart';
import 'login_world_card.dart';

class LoginWorldCarousel extends StatelessWidget {
  final PageController pageController;
  final int current;
  final double floatValue;
  final ValueChanged<int> onChanged;

  const LoginWorldCarousel({
    super.key,
    required this.pageController,
    required this.current,
    required this.floatValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: worlds.length,
            onPageChanged: onChanged,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: pageController,
                builder: (context, child) {
                  double diff = 0;
                  if (pageController.hasClients &&
                      pageController.position.haveDimensions) {
                    diff = ((pageController.page ?? current.toDouble()) - index).toDouble();
                  } else {
                    diff = (current - index).toDouble();
                  }
                  final scale = (1 - diff.abs() * .15).clamp(.78, 1.0).toDouble();
                  final y = (20 * diff.abs()).toDouble();

                  return Transform.translate(
                    offset: Offset(0, y),
                    child: Transform.scale(scale: scale, child: child),
                  );
                },
                child: LoginWorldCard(
                  world: worlds[index],
                  active: current == index,
                ),
              );
            },
          ),
          Positioned(
            top: 24 + math.sin(floatValue * math.pi * 2) * 8,
            left: 6,
            child: const BubbleAsset(
              'assets/art/bubbles/ciao.png',
              width: 82,
              angle: -.12,
            ),
          ),
          Positioned(
            top: 105 + math.cos(floatValue * math.pi * 2) * 6,
            right: 12,
            child: const BubbleAsset(
              'assets/art/bubbles/salut.png',
              width: 78,
              angle: .1,
            ),
          ),
          Positioned(
            bottom: 58 + math.sin(floatValue * math.pi * 2) * 7,
            left: 10,
            child: const BubbleAsset(
              'assets/art/bubbles/ola.png',
              width: 78,
              angle: -.1,
            ),
          ),
          Positioned(
            bottom: 48 + math.cos(floatValue * math.pi * 2) * 5,
            right: 8,
            child: const BubbleAsset(
              'assets/art/bubbles/hallo.png',
              width: 82,
              angle: .08,
            ),
          ),
          Positioned(
            top: 96 + math.sin(floatValue * math.pi * 2) * 8,
            right: 118,
            child: const BubbleAsset(
              'assets/art/bubbles/hello.png',
              width: 88,
              angle: .07,
            ),
          ),
        ],
      ),
    );
  }
}
'@

Write-DartFile "lib/features/auth/presentation/widgets/login_form_panel.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/divider_label.dart';
import '../../../../shared/widgets/premium_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/social_button.dart';

class LoginFormPanel extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool loading;
  final VoidCallback onTogglePassword;
  final VoidCallback onEnter;

  const LoginFormPanel({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.loading,
    required this.onTogglePassword,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PremiumTextField(
          controller: emailController,
          icon: Icons.mail_outline_rounded,
          hint: 'Correo electrónico',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        PremiumTextField(
          controller: passwordController,
          icon: Icons.lock_outline_rounded,
          hint: 'Contraseña',
          trailing: obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          obscureText: obscurePassword,
          onTrailingTap: onTogglePassword,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                color: Brand.mint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: 'Iniciar aventura',
          icon: Icons.auto_awesome_rounded,
          onTap: onEnter,
          loading: loading,
        ),
        const SizedBox(height: 14),
        OutlinedBrandButton(label: 'Crear cuenta', onTap: () {}),
        const SizedBox(height: 22),
        const DividerLabel(text: 'O continúa con'),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialButton(label: 'G'),
            SizedBox(width: 18),
            SocialButton(label: ''),
            SizedBox(width: 18),
            SocialButton(label: 'f'),
          ],
        ),
      ],
    );
  }
}
'@

Write-DartFile "lib/features/auth/presentation/pages/login_page.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/data/worlds_data.dart';
import '../../../../core/theme/brand.dart';
import '../../../../features/shell/app_shell.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../widgets/login_dots.dart';
import '../widgets/login_form_panel.dart';
import '../widgets/login_header.dart';
import '../widgets/login_world_carousel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _floatCtrl;
  late final AnimationController _pulseCtrl;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  int current = 0;
  bool loading = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: .62, initialPage: 0);
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
    _emailController = TextEditingController(text: 'estudiante@app.com');
    _passwordController = TextEditingController(text: '123456');

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      final next = (current + 1) % worlds.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 850),
          curve: Curves.easeOutCubic,
        );
      }
      return mounted;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _enter() async {
    if (loading) return;
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: const AppShell(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_floatCtrl, _pulseCtrl]),
        builder: (context, _) {
          return Stack(
            children: [
              const LearningBackground(),
              Positioned.fill(
                child: CustomPaint(
                  painter: LearningMotifPainter(t: _floatCtrl.value),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(22, 20, 22, bottom + 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 14),
                      const LoginHeader(),
                      const SizedBox(height: 24),
                      LoginWorldCarousel(
                        pageController: _pageController,
                        current: current,
                        floatValue: _floatCtrl.value,
                        onChanged: (i) => setState(() => current = i),
                      ),
                      LoginDots(current: current, total: worlds.length),
                      const SizedBox(height: 28),
                      LoginFormPanel(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: obscurePassword,
                        loading: loading,
                        onTogglePassword: () => setState(() {
                          obscurePassword = !obscurePassword;
                        }),
                        onEnter: _enter,
                      ),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: Brand.white.withOpacity(.52),
                            height: 1.45,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Al continuar, aceptas nuestros Términos y\n',
                            ),
                            TextSpan(
                              text: 'Política de privacidad',
                              style: TextStyle(color: Brand.mint),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
'@

Write-DartFile "lib/features/shell/app_shell.dart" @'
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
'@

Write-DartFile "lib/features/shell/brand_bottom_nav.dart" @'
import 'package:flutter/material.dart';

import '../../core/theme/brand.dart';

class BrandBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const BrandBottomNav({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.home_rounded, 'Inicio'),
      _NavItem(Icons.public_rounded, 'Mundos'),
      _NavItem(Icons.auto_graph_rounded, 'Avance'),
      _NavItem(Icons.person_rounded, 'Perfil'),
    ];

    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Brand.white.withOpacity(.10)),
        boxShadow: Brand.cardShadow,
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = index == i || (i == 1 && index == 2);
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: active ? Brand.mint : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: active ? Brand.glowMint : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[i].icon,
                      color: active ? Brand.bgDeep : Brand.white.withOpacity(.55),
                      size: 25,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        color: active ? Brand.bgDeep : Brand.white.withOpacity(.58),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
'@

Write-DartFile "lib/features/home/presentation/pages/home_page.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/data/worlds_data.dart';
import '../../../../core/models/world.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../../../shared/widgets/logo_mark.dart';
import '../../../../shared/widgets/metric_chip.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../features/course/presentation/widgets/mission_panel.dart';
import '../../../../features/progress/presentation/widgets/progress_summary.dart';
import '../widgets/compact_world_header.dart';
import '../widgets/world_mini_card.dart';

class HomePage extends StatelessWidget {
  final World world;
  final String level;
  final void Function(World) onWorldTap;
  final VoidCallback goMap;

  const HomePage({
    super.key,
    required this.world,
    required this.level,
    required this.onWorldTap,
    required this.goMap,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        const LearningBackground(),
        Positioned.fill(child: CustomPaint(painter: const LearningMotifPainter(t: .4))),
        SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 18, 20, bottom + 108),
            children: [
              const Row(
                children: [
                  Expanded(child: LogoMark(size: 32)),
                  MetricChip(icon: '🔥', title: 'Racha', value: '3 días'),
                  SizedBox(width: 10),
                  MetricChip(icon: '💎', title: 'XP', value: '1.420'),
                ],
              ),
              const SizedBox(height: 22),
              CompactWorldHeader(world: world, level: level, onTap: goMap),
              const SizedBox(height: 18),
              SectionTitle(title: 'Mundos disponibles', action: 'Ver todos', onAction: () {}),
              const SizedBox(height: 12),
              SizedBox(
                height: 214,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: worlds.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) => WorldMiniCard(
                    world: worlds[i],
                    active: worlds[i].id == world.id,
                    onTap: () => onWorldTap(worlds[i]),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: MissionPanel(compact: true)),
                  const SizedBox(width: 14),
                  Expanded(child: ProgressSummary(world: world)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
'@

Write-DartFile "lib/features/home/presentation/widgets/compact_world_header.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/progress_bar.dart';

class CompactWorldHeader extends StatelessWidget {
  final World world;
  final String level;
  final VoidCallback onTap;

  const CompactWorldHeader({
    super.key,
    required this.world,
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Brand.white.withOpacity(.09)),
        boxShadow: Brand.cardShadow,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 88,
              height: 88,
              color: Brand.bgDeep.withOpacity(.55),
              child: Image.asset(world.image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mundo actual',
                  style: TextStyle(color: Brand.muted, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  '${world.language} · ${world.city}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(child: ProgressBar(value: .45)),
                    const SizedBox(width: 10),
                    Text(
                      '45%  $level',
                      style: const TextStyle(color: Brand.mint, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Continuar misión',
                  icon: Icons.sports_esports_rounded,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
'@

Write-DartFile "lib/features/home/presentation/widgets/world_mini_card.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';

class WorldMiniCard extends StatelessWidget {
  final World world;
  final bool active;
  final VoidCallback onTap;

  const WorldMiniCard({
    super.key,
    required this.world,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? Brand.mint : Brand.bgPanel.withOpacity(.64),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: active ? Brand.mint : Brand.white.withOpacity(.10),
          ),
          boxShadow: active ? Brand.glowMint : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Center(child: Image.asset(world.image, fit: BoxFit.contain))),
            Text(
              world.language,
              style: TextStyle(
                color: active ? Brand.bgDeep : Brand.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              world.city,
              style: TextStyle(
                color: active ? Brand.bgDeep.withOpacity(.75) : Brand.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
'@

Write-DartFile "lib/features/worlds/presentation/pages/worlds_page.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/data/worlds_data.dart';
import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../../../shared/widgets/logo_mark.dart';
import '../widgets/level_chip.dart';
import '../widgets/world_large_card.dart';

class WorldsPage extends StatefulWidget {
  final World selected;
  final String level;
  final void Function(World, String) onSelect;

  const WorldsPage({
    super.key,
    required this.selected,
    required this.level,
    required this.onSelect,
  });

  @override
  State<WorldsPage> createState() => _WorldsPageState();
}

class _WorldsPageState extends State<WorldsPage> {
  late String level;

  @override
  void initState() {
    super.initState();
    level = widget.level;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        const LearningBackground(),
        Positioned.fill(child: CustomPaint(painter: const LearningMotifPainter(t: .8))),
        SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 108),
            children: [
              const LogoMark(size: 32),
              const SizedBox(height: 18),
              const Text(
                'Elige tu mundo',
                style: TextStyle(fontSize: 34, height: 1, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cada idioma tiene una ruta, misiones y recompensas diferentes.',
                style: TextStyle(color: Brand.muted, fontSize: 15, height: 1.35),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: ['A1', 'A2', 'B1', 'B2', 'C1']
                    .map(
                      (l) => LevelChip(
                        label: l,
                        active: level == l,
                        onTap: () => setState(() => level = l),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 22),
              ...worlds.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: WorldLargeCard(
                    world: w,
                    active: w.id == widget.selected.id,
                    onTap: () => widget.onSelect(w, level),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
'@

Write-DartFile "lib/features/worlds/presentation/widgets/level_chip.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

class LevelChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const LevelChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: active ? Brand.mint : Brand.bgPanel.withOpacity(.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: active ? Brand.mint : Brand.white.withOpacity(.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Brand.bgDeep : Brand.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
'@

Write-DartFile "lib/features/worlds/presentation/widgets/world_large_card.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/progress_bar.dart';

class WorldLargeCard extends StatelessWidget {
  final World world;
  final bool active;
  final VoidCallback onTap;

  const WorldLargeCard({
    super.key,
    required this.world,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        height: 190,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Brand.bgPanel.withOpacity(.70),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active ? Brand.mint : Brand.white.withOpacity(.10),
            width: active ? 2 : 1,
          ),
          boxShadow: active ? Brand.glowMint : Brand.cardShadow,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Hero(
                tag: 'world-${world.id}',
                child: Image.asset(world.image, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${world.flag} ${world.language}',
                    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    world.city,
                    style: const TextStyle(color: Brand.muted, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  const ProgressBar(value: .45),
                  const SizedBox(height: 12),
                  Text(
                    active ? 'Mundo activo' : 'Tocar para entrar',
                    style: TextStyle(
                      color: active ? Brand.mint : Brand.cyan,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
'@

Write-DartFile "lib/features/course/presentation/pages/course_map_page.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/asset_widgets.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../../../shared/widgets/logo_mark.dart';
import '../../../../shared/widgets/metric_chip.dart';
import '../painters/city_silhouette_painter.dart';
import '../painters/game_path_painter.dart';
import '../widgets/current_world_bar.dart';
import '../widgets/final_challenge_card.dart';
import '../widgets/lesson_card.dart';
import '../widgets/lesson_node.dart';
import '../widgets/mission_panel.dart';

class CourseMapPage extends StatefulWidget {
  final World world;
  final String level;
  final VoidCallback onChangeWorld;

  const CourseMapPage({
    super.key,
    required this.world,
    required this.level,
    required this.onChangeWorld,
  });

  @override
  State<CourseMapPage> createState() => _CourseMapPageState();
}

class _CourseMapPageState extends State<CourseMapPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        const LearningBackground(),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: ctrl,
            builder: (_, __) => CustomPaint(
              painter: LearningMotifPainter(t: ctrl.value),
            ),
          ),
        ),
        SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 14, 20, bottom + 108),
            children: [
              const Row(
                children: [
                  Expanded(child: LogoMark(size: 28)),
                  MetricChip(icon: '🔥', title: 'Racha', value: '3 días'),
                  SizedBox(width: 10),
                  MetricChip(icon: '💎', title: 'XP', value: '1.420'),
                ],
              ),
              const SizedBox(height: 16),
              CurrentWorldBar(
                world: widget.world,
                level: widget.level,
                onChange: widget.onChangeWorld,
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: ctrl,
                builder: (_, __) {
                  return SizedBox(
                    height: 1080,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFF23023D).withOpacity(.32),
                              borderRadius: BorderRadius.circular(34),
                              border: Border.all(color: const Color(0xFF3B2369).withOpacity(.65)),
                            ),
                          ),
                        ),
                        Positioned.fill(child: CustomPaint(painter: CitySilhouettePainter(world: widget.world))),
                        Positioned.fill(child: CustomPaint(painter: GamePathPainter(progress: ctrl.value))),
                        Positioned(
                          top: 20,
                          left: 4,
                          right: 4,
                          child: Hero(
                            tag: 'world-${widget.world.id}',
                            child: Image.asset(widget.world.image, height: 235, fit: BoxFit.contain),
                          ),
                        ),
                        const Positioned(top: 250, left: 16, child: DecorImage('assets/art/decor/cloud.png', width: 90, opacity: .45)),
                        const Positioned(top: 320, right: 14, child: DecorImage('assets/art/decor/bushes.png', width: 130, opacity: .72)),
                        const Positioned(top: 440, left: 10, child: DecorImage('assets/art/decor/lamp.png', width: 62, opacity: .95)),
                        const Positioned(top: 520, right: 24, child: DecorImage('assets/art/decor/bench.png', width: 120, opacity: .9)),
                        const Positioned(top: 660, left: 22, child: DecorImage('assets/art/decor/tree.png', width: 118, opacity: .82)),
                        Positioned(top: 865, right: 24, child: FloatingAsset('assets/art/ui/chest.png', width: 145, t: ctrl.value)),
                        _lessonNode(1, const Offset(68, 280), widget.world.lessons[0], true, true),
                        _lessonNode(2, const Offset(255, 405), widget.world.lessons[1], true, true),
                        _lessonNode(3, const Offset(95, 565), widget.world.lessons[2], true, true),
                        _lessonNode(4, const Offset(255, 705), widget.world.lessons[3], true, true),
                        _lessonNode(5, const Offset(88, 845), widget.world.lessons[4], false, false),
                        _lessonNode(6, const Offset(242, 940), widget.world.lessons[5], false, false),
                        const Positioned(top: 835, left: 8, width: 215, child: MissionPanel(compact: false)),
                        const Positioned(top: 945, right: 20, width: 185, child: FinalChallengeCard()),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _lessonNode(
    int num,
    Offset pos,
    String title,
    bool unlocked,
    bool cardRight,
  ) {
    final cardLeft = cardRight ? pos.dx + 72 : pos.dx - 165;
    return Stack(
      children: [
        Positioned(left: pos.dx, top: pos.dy, child: LessonNode(number: num, unlocked: unlocked)),
        Positioned(left: cardLeft, top: pos.dy - 4, width: 158, child: LessonCard(title: title, unlocked: unlocked, start: num == 1)),
      ],
    );
  }
}
'@

New-Item -ItemType Directory -Force -Path "lib/features/course/presentation/painters" | Out-Null

Write-DartFile "lib/features/course/presentation/painters/game_path_painter.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

class GamePathPainter extends CustomPainter {
  final double progress;

  const GamePathPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final pts = [
      Offset(size.width * .23, 315),
      Offset(size.width * .72, 405),
      Offset(size.width * .25, 555),
      Offset(size.width * .72, 705),
      Offset(size.width * .25, 855),
      Offset(size.width * .67, 965),
    ];

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      path.cubicTo(a.dx, (a.dy + b.dy) / 2, b.dx, (a.dy + b.dy) / 2, b.dx, b.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 50
        ..strokeCap = StrokeCap.round
        ..color = Brand.purple.withOpacity(.55),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 32
        ..strokeCap = StrokeCap.round
        ..color = Brand.purple.withOpacity(.88),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Brand.mint.withOpacity(.92),
    );

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    for (int i = 0; i < 18; i++) {
      final f = (progress + i / 18) % 1;
      final pos = metric.getTangentForOffset(metric.length * f)?.position;
      if (pos != null) {
        canvas.drawCircle(pos, 2.4, Paint()..color = Brand.cyan.withOpacity(.85));
      }
    }
  }

  @override
  bool shouldRepaint(covariant GamePathPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
'@

Write-DartFile "lib/features/course/presentation/painters/city_silhouette_painter.dart" @'
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';

class CitySilhouettePainter extends CustomPainter {
  final World world;

  const CitySilhouettePainter({required this.world});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Brand.navy.withOpacity(.28);
    final rnd = math.Random(world.id.hashCode);

    for (int i = 0; i < 12; i++) {
      final w = 38.0 + rnd.nextInt(40);
      final h = 140.0 + rnd.nextInt(240);
      final x = rnd.nextDouble() * size.width;
      final y = 170.0 + rnd.nextDouble() * (size.height - 260);
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(10),
      );
      canvas.drawRRect(r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CitySilhouettePainter oldDelegate) {
    return oldDelegate.world != world;
  }
}
'@

Write-DartFile "lib/features/course/presentation/widgets/current_world_bar.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/progress_bar.dart';

class CurrentWorldBar extends StatelessWidget {
  final World world;
  final String level;
  final VoidCallback onChange;

  const CurrentWorldBar({
    super.key,
    required this.world,
    required this.level,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.58),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Brand.white.withOpacity(.10)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 80,
              height: 80,
              color: Brand.bgDeep,
              child: Image.asset(world.image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Mundo actual',
                  style: TextStyle(color: Brand.muted, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${world.language} · ${world.city}',
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Expanded(child: ProgressBar(value: .45)),
                    const SizedBox(width: 9),
                    const Text('45%', style: TextStyle(color: Brand.muted, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Text(level, style: const TextStyle(color: Brand.mint, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onChange,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Brand.navy.withOpacity(.45),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(Icons.map_rounded, color: Brand.mint, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
'@

Write-DartFile "lib/features/course/presentation/widgets/lesson_node.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

class LessonNode extends StatelessWidget {
  final int number;
  final bool unlocked;

  const LessonNode({
    super.key,
    required this.number,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: unlocked ? Brand.mintDark : Brand.line,
        border: Border.all(color: Brand.white, width: 3),
        boxShadow: unlocked ? Brand.glowMint : null,
      ),
      child: Center(
        child: unlocked
            ? Text(
                '$number',
                style: const TextStyle(
                  fontSize: 28,
                  color: Brand.bgDeep,
                  fontWeight: FontWeight.w900,
                ),
              )
            : const Icon(Icons.lock_rounded, color: Brand.white),
      ),
    );
  }
}
'@

Write-DartFile "lib/features/course/presentation/widgets/lesson_card.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

class LessonCard extends StatelessWidget {
  final String title;
  final bool unlocked;
  final bool start;

  const LessonCard({
    super.key,
    required this.title,
    required this.unlocked,
    this.start = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: unlocked ? Brand.cyan.withOpacity(.55) : Brand.white.withOpacity(.08),
        ),
        boxShadow: Brand.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (start)
            const Text(
              '¡Empieza aquí!',
              style: TextStyle(color: Brand.mint, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, height: 1.25),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(unlocked ? Icons.check_circle : Icons.lock, color: unlocked ? Brand.mint : Brand.muted, size: 19),
              const SizedBox(width: 6),
              Text(
                unlocked ? 'Completado' : 'Bloqueado',
                style: TextStyle(color: unlocked ? Brand.mint : Brand.muted, fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
'@

Write-DartFile "lib/features/course/presentation/widgets/mission_panel.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/progress_bar.dart';

class MissionPanel extends StatelessWidget {
  final bool compact;

  const MissionPanel({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.68),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Brand.white.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Misiones diarias', style: TextStyle(fontSize: compact ? 18 : 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('2/3 completas', style: TextStyle(color: Brand.muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const MissionItem(title: 'Practica 10 frases', progress: '8/10', value: .8, xp: '20'),
          const MissionItem(title: 'Escucha 5 diálogos', progress: '5/5', value: 1, xp: '15', active: true),
          if (!compact) const MissionItem(title: 'Aprende 3 palabras', progress: '2/3', value: .66, xp: '10'),
          const SizedBox(height: 10),
          Container(
            height: 48,
            decoration: BoxDecoration(color: Brand.mint, borderRadius: BorderRadius.circular(16)),
            child: const Center(
              child: Text(
                'Ver todas las misiones',
                style: TextStyle(color: Brand.bgDeep, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MissionItem extends StatelessWidget {
  final String title;
  final String progress;
  final String xp;
  final double value;
  final bool active;

  const MissionItem({
    super.key,
    required this.title,
    required this.progress,
    required this.value,
    required this.xp,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: active ? Brand.navy.withOpacity(.48) : Brand.bgDeep.withOpacity(.36),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
              Text('⭐ $xp', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Text(progress, style: const TextStyle(color: Brand.mint, fontSize: 12, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Expanded(child: ProgressBar(value: value)),
            ],
          ),
        ],
      ),
    );
  }
}
'@

Write-DartFile "lib/features/course/presentation/widgets/final_challenge_card.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

class FinalChallengeCard extends StatelessWidget {
  const FinalChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Brand.white.withOpacity(.08)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reto final', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          SizedBox(height: 6),
          Text('Completa para ganar XP extra 💎', style: TextStyle(color: Brand.muted, height: 1.3)),
        ],
      ),
    );
  }
}
'@

New-Item -ItemType Directory -Force -Path "lib/features/progress/presentation/widgets" | Out-Null

Write-DartFile "lib/features/progress/presentation/pages/progress_page.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/painters/learning_motif_painter.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../../../shared/widgets/logo_mark.dart';
import '../../../../features/course/presentation/widgets/mission_panel.dart';
import '../widgets/progress_summary.dart';

class ProgressPage extends StatelessWidget {
  final World world;

  const ProgressPage({super.key, required this.world});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        const LearningBackground(),
        Positioned.fill(child: CustomPaint(painter: const LearningMotifPainter(t: .2))),
        SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 22, 20, bottom + 108),
            children: [
              const LogoMark(size: 30),
              const SizedBox(height: 22),
              const Text('Tu avance', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Resumen quemado mientras conectamos datos reales.', style: TextStyle(color: Brand.muted)),
              const SizedBox(height: 18),
              ProgressSummary(world: world, large: true),
              const SizedBox(height: 18),
              const MissionPanel(compact: false),
            ],
          ),
        ),
      ],
    );
  }
}
'@

Write-DartFile "lib/features/progress/presentation/widgets/progress_summary.dart" @'
import 'package:flutter/material.dart';

import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/progress_bar.dart';

class ProgressSummary extends StatelessWidget {
  final World world;
  final bool large;

  const ProgressSummary({
    super.key,
    required this.world,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(.68),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Brand.white.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tu avance', style: TextStyle(fontSize: large ? 24 : 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Center(child: Image.asset(world.image, height: large ? 210 : 94)),
          const SizedBox(height: 10),
          const Text('45% completado', style: TextStyle(color: Brand.mint, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const ProgressBar(value: .45),
        ],
      ),
    );
  }
}
'@

Write-DartFile "lib/features/profile/presentation/pages/profile_page.dart" @'
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
              const ProfileTile(icon: Icons.settings_outlined, title: 'Configuración'),
            ],
          ),
        ),
      ],
    );
  }
}
'@

New-Item -ItemType Directory -Force -Path "lib/features/profile/presentation/widgets" | Out-Null

Write-DartFile "lib/features/profile/presentation/widgets/profile_tile.dart" @'
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
'@

Write-Host "\nRefactor completo creado correctamente." -ForegroundColor Cyan
Write-Host "Ahora ejecuta:" -ForegroundColor Cyan
Write-Host "flutter clean" -ForegroundColor Yellow
Write-Host "flutter pub get" -ForegroundColor Yellow
Write-Host "flutter run" -ForegroundColor Yellow
Write-Host "\nRevisa que pubspec.yaml tenga estos assets:" -ForegroundColor Cyan
Write-Host "  - assets/art/worlds/" -ForegroundColor Yellow
Write-Host "  - assets/art/bubbles/" -ForegroundColor Yellow
Write-Host "  - assets/art/decor/" -ForegroundColor Yellow
Write-Host "  - assets/art/ui/" -ForegroundColor Yellow
