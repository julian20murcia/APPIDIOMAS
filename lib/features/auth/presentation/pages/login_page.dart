import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/data/worlds_data.dart';
import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../features/shell/app_shell.dart';
import '../widgets/login_form_panel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _floatCtrl;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  int current = 0;
  bool loading = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    )..forward();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7200),
    )..repeat();

    _emailController = TextEditingController(text: 'estudiante@app.com');
    _passwordController = TextEditingController(text: '123456');
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _enter() async {
    if (loading) return;

    FocusScope.of(context).unfocus();
    setState(() => loading = true);

    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 680),
        reverseTransitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, animation, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.985,
                end: 1,
              ).animate(curved),
              child: const AppShell(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final bottom = media.padding.bottom;
    final keyboard = media.viewInsets.bottom;
    final keyboardOpen = keyboard > 0;

    final compact = size.height < 920 || keyboardOpen;
    final veryCompact = size.height < 780 || keyboardOpen;

    final selectedWorld = worlds[current];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Brand.bgDeep,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _entryCtrl,
          _floatCtrl,
        ]),
        builder: (context, _) {
          final entry = Curves.easeOutCubic.transform(_entryCtrl.value);

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _LoginBackgroundPainter(t: _floatCtrl.value),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        18,
                        veryCompact ? 6 : 12,
                        18,
                        bottom + keyboard + 20,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - bottom,
                        ),
                        child: Transform.translate(
                          offset: Offset(0, 12 * (1 - entry)),
                          child: Opacity(
                            opacity: entry,
                            child: Column(
                              children: [
                                if (keyboardOpen)
                                  _KeyboardHeader(world: selectedWorld)
                                else ...[
                                  _HeroSection(
                                    compact: compact,
                                    veryCompact: veryCompact,
                                    t: _floatCtrl.value,
                                  ),
                                  SizedBox(height: compact ? 12 : 14),
                                  _LanguageSelector(
                                    current: current,
                                    compact: compact,
                                    onSelected: (index) {
                                      setState(() => current = index);
                                    },
                                  ),
                                ],
                                SizedBox(height: compact ? 16 : 18),
                                LoginFormPanel(
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  obscurePassword: obscurePassword,
                                  loading: loading,
                                  compact: compact,
                                  onTogglePassword: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                  onEnter: _enter,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool compact;
  final bool veryCompact;
  final double t;

  const _HeroSection({
    required this.compact,
    required this.veryCompact,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final logoFont = veryCompact
        ? 48.0
        : compact
            ? 54.0
            : 64.0;

    final titleFont = veryCompact
        ? 17.8
        : compact
            ? 20.0
            : 22.0;

    final subtitleFont = veryCompact
        ? 11.3
        : compact
            ? 12.2
            : 13.2;

    final mapHeight = veryCompact
        ? 180.0
        : compact
            ? 215.0
            : 250.0;

    return Column(
      children: [
        _LingoVerseLogo(fontSize: logoFont),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            style: TextStyle(
              color: Brand.white.withOpacity(0.96),
              fontSize: titleFont,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.35,
            ),
            children: const [
              TextSpan(text: 'Aprende idiomas '),
              TextSpan(
                text: '.',
                style: TextStyle(color: Brand.mint),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Rutas interactivas, niveles y desafíos\npara avanzar cada día.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Brand.white.withOpacity(0.62),
            fontSize: subtitleFont,
            height: 1.18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: compact ? 12 : 14),
        _HeroMapImage(
          height: mapHeight,
          t: t,
        ),
      ],
    );
  }
}

class _LingoVerseLogo extends StatelessWidget {
  final double fontSize;

  const _LingoVerseLogo({
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Lingo',
              style: TextStyle(
                color: Brand.white,
                fontSize: fontSize,
                height: 0.95,
                fontWeight: FontWeight.w900,
                letterSpacing: -2.2,
              ),
            ),
            TextSpan(
              text: 'Verse',
              style: TextStyle(
                color: Brand.mint,
                fontSize: fontSize,
                height: 0.95,
                fontWeight: FontWeight.w900,
                letterSpacing: -2.2,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _HeroMapImage extends StatelessWidget {
  final double height;
  final double t;

  const _HeroMapImage({
    required this.height,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final floatY = math.sin(t * math.pi * 2) * 2.0;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Transform.translate(
        offset: Offset(0, floatY),
        child: Image.asset(
          'assets/art/ui/login_hero_map.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final int current;
  final bool compact;
  final ValueChanged<int> onSelected;

  const _LanguageSelector({
    required this.current,
    required this.compact,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 50 : 58,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.38),
        borderRadius: Brand.radiusPill,
        border: Border.all(
          color: Brand.white.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: List.generate(worlds.length, (index) {
          final world = worlds[index];
          final active = current == index;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                height: compact ? 36 : 44,
                margin: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 6,
                ),
                padding: EdgeInsets.symmetric(horizontal: active ? 6 : 2),
                decoration: BoxDecoration(
                  color: active
                      ? Brand.bgPanel.withOpacity(0.92)
                      : Colors.transparent,
                  borderRadius: Brand.radiusPill,
                  border: Border.all(
                    color: active
                        ? Brand.mint.withOpacity(0.90)
                        : Colors.transparent,
                    width: active ? 1.15 : 1,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: Brand.mint.withOpacity(0.18),
                            blurRadius: 16,
                            spreadRadius: -10,
                            offset: const Offset(0, 7),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: compact ? 22 : 26,
                      height: compact ? 22 : 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Brand.bgDeep.withOpacity(0.54),
                        border: Border.all(
                          color: Brand.white.withOpacity(0.15),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          world.flag,
                          style: TextStyle(fontSize: compact ? 12 : 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          world.language,
                          maxLines: 1,
                          style: TextStyle(
                            color: active
                                ? Brand.mint
                                : Brand.white.withOpacity(0.76),
                            fontSize: compact ? 10.5 : 12.4,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.08,
                          ),
                        ),
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

class _KeyboardHeader extends StatelessWidget {
  final World world;

  const _KeyboardHeader({
    required this.world,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.60),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Brand.white.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          const _LingoVerseLogo(fontSize: 24),
          const Spacer(),
          Text(world.flag, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            world.language,
            style: const TextStyle(
              color: Brand.mint,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackgroundPainter extends CustomPainter {
  final double t;

  _LoginBackgroundPainter({
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Brand.navy,
          Brand.bgDeep,
          Brand.bgPanel,
        ],
      ).createShader(rect);

    canvas.drawRect(rect, bgPaint);

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.10),
      size.width * 0.30,
      Paint()..color = Brand.cyan.withOpacity(0.05),
    );

    canvas.drawCircle(
      Offset(size.width * 0.47, size.height * 0.18),
      size.width * 0.40,
      Paint()..color = Brand.cyan.withOpacity(0.065),
    );

    canvas.drawCircle(
      Offset(size.width * 0.06, size.height * 0.92),
      size.width * 0.42,
      Paint()..color = Brand.purple.withOpacity(0.18),
    );

    final starPaint = Paint()
      ..color = Brand.white.withOpacity(0.38)
      ..style = PaintingStyle.fill;

    final mintStarPaint = Paint()
      ..color = Brand.mint.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 18; i++) {
      final x = size.width * ((i * 0.137 + t * 0.030) % 1.0);
      final y = size.height * (0.05 + ((i * 0.173) % 0.84));
      final r = i % 4 == 0 ? 1.4 : 0.82;

      canvas.drawCircle(
        Offset(x, y),
        r,
        i % 3 == 0 ? mintStarPaint : starPaint,
      );
    }

    final orbitPaint = Paint()
      ..color = Brand.white.withOpacity(0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final orbitPath = Path()
      ..moveTo(size.width * 0.02, size.height * 0.205)
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * 0.12,
        size.width * 0.44,
        size.height * 0.18,
      );

    canvas.drawPath(orbitPath, orbitPaint);

    final planePaint = Paint()
      ..color = Brand.cyan.withOpacity(0.36)
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;

    final px = size.width * (0.18 + math.sin(t * math.pi * 2) * 0.014);
    final py = size.height * 0.17;

    canvas.drawLine(
      Offset(px - 10, py + 5),
      Offset(px + 11, py - 5),
      planePaint,
    );
    canvas.drawLine(
      Offset(px + 3, py - 3),
      Offset(px + 10, py + 6),
      planePaint,
    );
    canvas.drawLine(
      Offset(px - 1, py + 2),
      Offset(px - 9, py - 2),
      planePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LoginBackgroundPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}