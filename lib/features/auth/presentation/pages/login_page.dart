import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/data/worlds_data.dart';
import '../../../../core/models/world.dart';
import '../../../../core/theme/brand.dart';
import '../../../../features/shell/app_shell.dart';
import '../../../../shared/widgets/logo_mark.dart';
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
      duration: const Duration(milliseconds: 720),
    )..forward();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6200),
    )..repeat();

    _emailController = TextEditingController(text: 'estudiante@app.com');
    _passwordController = TextEditingController(text: '123456');

    _startWorldAutoPlay();
  }

  void _startWorldAutoPlay() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));

      if (!mounted) return false;

      setState(() {
        current = (current + 1) % worlds.length;
      });

      return mounted;
    });
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
    final height = media.size.height;
    final bottom = media.padding.bottom;
    final keyboard = media.viewInsets.bottom;

    final keyboardOpen = keyboard > 0;
    final compact = height < 820 || keyboardOpen;
    final veryCompact = height < 730 || keyboardOpen;
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
                  painter: _GameCleanBackgroundPainter(
                    t: _floatCtrl.value,
                  ),
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
                        22,
                        veryCompact ? 8 : 14,
                        22,
                        bottom + keyboard + 16,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight -
                              bottom -
                              keyboard -
                              16,
                        ),
                        child: Transform.translate(
                          offset: Offset(0, 18 * (1 - entry)),
                          child: Opacity(
                            opacity: entry,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _TopBrandBlock(
                                  compact: compact,
                                ),

                                SizedBox(height: veryCompact ? 14 : 18),

                                if (!keyboardOpen) ...[
                                  _WorldGameCard(
                                    world: selectedWorld,
                                    compact: compact,
                                    veryCompact: veryCompact,
                                    t: _floatCtrl.value,
                                  ),

                                  SizedBox(height: veryCompact ? 10 : 12),

                                  _FlagSelector(
                                    current: current,
                                    onSelected: (index) {
                                      setState(() => current = index);
                                    },
                                  ),

                                  SizedBox(height: veryCompact ? 14 : 18),
                                ] else ...[
                                  _WorldMiniHeader(world: selectedWorld),
                                  const SizedBox(height: 14),
                                ],

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

class _TopBrandBlock extends StatelessWidget {
  final bool compact;

  const _TopBrandBlock({
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LogoMark(
          center: true,
          size: compact ? 42 : 50,
        ),

        SizedBox(height: compact ? 8 : 10),

        Text.rich(
          TextSpan(
            style: TextStyle(
              color: Brand.white.withOpacity(0.78),
              fontSize: compact ? 15 : 16.5,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
            children: const [
              TextSpan(text: 'Aprende idiomas '),
              TextSpan(
                text: 'jugando',
                style: TextStyle(
                  color: Brand.mint,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),

        if (!compact) ...[
          const SizedBox(height: 5),
          Text(
            'Rutas, niveles y desafíos para avanzar cada día.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Brand.white.withOpacity(0.45),
              fontSize: 12.5,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _WorldGameCard extends StatelessWidget {
  final World world;
  final bool compact;
  final bool veryCompact;
  final double t;

  const _WorldGameCard({
    required this.world,
    required this.compact,
    required this.veryCompact,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = veryCompact
        ? 155.0
        : compact
            ? 168.0
            : 190.0;

    final imageSize = veryCompact
        ? 142.0
        : compact
            ? 158.0
            : 182.0;

    final imageMove = math.sin(t * math.pi * 2) * 4;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Container(
        key: ValueKey(world.id),
        height: cardHeight,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 18,
          compact ? 15 : 17,
          compact ? 12 : 14,
          compact ? 14 : 16,
        ),
        decoration: BoxDecoration(
          color: Brand.bgPanel.withOpacity(0.58),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Brand.mint.withOpacity(0.28),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
              spreadRadius: -14,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -42,
                top: -52,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Brand.cyan.withOpacity(0.08),
                  ),
                ),
              ),

              Positioned(
                left: -34,
                bottom: -48,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Brand.purple.withOpacity(0.16),
                  ),
                ),
              ),

              Positioned(
                right: -8,
                bottom: -12 + imageMove,
                width: imageSize,
                child: Image.asset(
                  world.image,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),

              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: imageSize * 0.68,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      decoration: BoxDecoration(
                        color: Brand.bgDeep.withOpacity(0.56),
                        borderRadius: Brand.radiusPill,
                        border: Border.all(
                          color: Brand.white.withOpacity(0.10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            world.flag,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            world.hello,
                            style: const TextStyle(
                              color: Brand.mint,
                              fontSize: 12.3,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Text(
                      world.language,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Brand.white,
                        fontSize: compact ? 25 : 30,
                        height: 0.92,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      world.city,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Brand.mint,
                        fontSize: compact ? 14 : 15.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _MiniQuestChip(
                          icon: Icons.star_rounded,
                          label: 'Nivel 1',
                        ),
                        const SizedBox(width: 7),
                        _MiniQuestChip(
                          icon: Icons.route_rounded,
                          label: 'Ruta',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniQuestChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniQuestChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Brand.bgDeep.withOpacity(0.48),
        borderRadius: Brand.radiusPill,
        border: Border.all(
          color: Brand.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Brand.mint,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Brand.white.withOpacity(0.64),
              fontSize: 10.8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagSelector extends StatelessWidget {
  final int current;
  final ValueChanged<int> onSelected;

  const _FlagSelector({
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.36),
        borderRadius: Brand.radiusPill,
        border: Border.all(
          color: Brand.white.withOpacity(0.075),
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
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: active ? 42 : 36,
                  height: active ? 42 : 36,
                  decoration: BoxDecoration(
                    color: active ? Brand.mint : Brand.bgDeep.withOpacity(0.52),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active
                          ? Brand.mint
                          : Brand.white.withOpacity(0.08),
                    ),
                    boxShadow: active ? Brand.glowMint : null,
                  ),
                  child: Center(
                    child: Text(
                      world.flag,
                      style: TextStyle(
                        fontSize: active ? 19 : 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _WorldMiniHeader extends StatelessWidget {
  final World world;

  const _WorldMiniHeader({
    required this.world,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.58),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Brand.white.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Text(
            world.flag,
            style: const TextStyle(fontSize: 23),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${world.language} · ${world.city}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Brand.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            world.hello,
            style: const TextStyle(
              color: Brand.mint,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCleanBackgroundPainter extends CustomPainter {
  final double t;

  _GameCleanBackgroundPainter({
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
      Offset(size.width * 0.50, size.height * 0.18),
      size.width * 0.44,
      Paint()..color = Brand.cyan.withOpacity(0.055),
    );

    canvas.drawCircle(
      Offset(size.width * 0.02, size.height * 0.92),
      size.width * 0.42,
      Paint()..color = Brand.purple.withOpacity(0.17),
    );

    final routePaint = Paint()
      ..color = Brand.white.withOpacity(0.04)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.25 + i * 0.18);
      final move = math.sin((t * math.pi * 2) + i) * 7;

      final path = Path()
        ..moveTo(-20, y + move)
        ..quadraticBezierTo(
          size.width * 0.50,
          y - 22 - move,
          size.width + 20,
          y + move,
        );

      canvas.drawPath(path, routePaint);
    }

    final dotPaint = Paint()
      ..color = Brand.mint.withOpacity(0.10)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final x = size.width * ((i * 0.17 + t * 0.07) % 1.0);
      final y = size.height * (0.10 + ((i * 0.13) % 0.78));
      canvas.drawCircle(
        Offset(x, y),
        i % 3 == 0 ? 2.7 : 1.8,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GameCleanBackgroundPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}