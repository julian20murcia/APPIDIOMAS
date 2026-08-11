import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../features/shell/app_shell.dart';
import '../widgets/login_form_panel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _ambientController;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool loading = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _emailController = TextEditingController(
      text: 'estudiante@app.com',
    );

    _passwordController = TextEditingController(
      text: '123456',
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _ambientController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  Future<void> _enter() async {
    if (loading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.99,
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

    final width = media.size.width;
    final height = media.size.height;
    final keyboardHeight = media.viewInsets.bottom;

    final keyboardOpen = keyboardHeight > 0;
    final compact = height < 780 || width < 380;
    final wide = width >= 900 && !keyboardOpen;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _LoginColors.ivory,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _entryController,
          _ambientController,
        ]),
        builder: (context, _) {
          final entry = Curves.easeOutCubic.transform(
            _entryController.value,
          );

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _PremiumBackgroundPainter(
                    t: _ambientController.value,
                  ),
                ),
              ),

              SafeArea(
                child: Opacity(
                  opacity: entry,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      12 * (1 - entry),
                    ),
                    child: wide
                        ? _WideLayout(
                            emailController: _emailController,
                            passwordController: _passwordController,
                            obscurePassword: obscurePassword,
                            loading: loading,
                            onTogglePassword: _togglePassword,
                            onEnter: _enter,
                          )
                        : _MobileLayout(
                            compact: compact,
                            keyboardOpen: keyboardOpen,
                            keyboardHeight: keyboardHeight,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            obscurePassword: obscurePassword,
                            loading: loading,
                            onTogglePassword: _togglePassword,
                            onEnter: _enter,
                          ),
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

class _MobileLayout extends StatelessWidget {
  final bool compact;
  final bool keyboardOpen;
  final double keyboardHeight;

  final TextEditingController emailController;
  final TextEditingController passwordController;

  final bool obscurePassword;
  final bool loading;

  final VoidCallback onTogglePassword;
  final VoidCallback onEnter;

  const _MobileLayout({
    required this.compact,
    required this.keyboardOpen,
    required this.keyboardHeight,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.loading,
    required this.onTogglePassword,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        18,
        keyboardOpen ? 8 : 14,
        18,
        keyboardHeight + media.padding.bottom + 20,
      ),
      child: Column(
        children: [
          if (keyboardOpen)
            const _CompactLogo()
          else
            _Hero(
              compact: compact,
            ),

          SizedBox(
            height: keyboardOpen
                ? 12
                : compact
                    ? 18
                    : 24,
          ),

          LoginFormPanel(
            emailController: emailController,
            passwordController: passwordController,
            obscurePassword: obscurePassword,
            loading: loading,
            compact: compact || keyboardOpen,
            onTogglePassword: onTogglePassword,
            onEnter: onEnter,
          ),
        ],
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final bool obscurePassword;
  final bool loading;

  final VoidCallback onTogglePassword;
  final VoidCallback onEnter;

  const _WideLayout({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.loading,
    required this.onTogglePassword,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1100,
        ),
        child: Row(
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: _Hero(
                  compact: false,
                ),
              ),
            ),

            const SizedBox(width: 30),

            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 440,
                ),
                child: LoginFormPanel(
                  emailController: emailController,
                  passwordController: passwordController,
                  obscurePassword: obscurePassword,
                  loading: loading,
                  compact: false,
                  onTogglePassword: onTogglePassword,
                  onEnter: onEnter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final bool compact;

  const _Hero({
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final logoWidth = width >= 900
        ? 350.0
        : compact
            ? 225.0
            : 270.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: logoWidth,
          child: Image.asset(
            'assets/art/brand/lingoverse_logo_full.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return const _FallbackLogo();
            },
          ),
        ),

        SizedBox(
          height: compact ? 16 : 22,
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 1,
              color: _LoginColors.gold.withOpacity(0.45),
            ),
            const SizedBox(width: 9),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: _LoginColors.gold,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 9),
            Container(
              width: 32,
              height: 1,
              color: _LoginColors.gold.withOpacity(0.45),
            ),
          ],
        ),

        SizedBox(
          height: compact ? 15 : 20,
        ),

        Text(
          'Aprende sin fronteras.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _LoginColors.navy,
            fontSize: compact ? 25 : 30,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),

        SizedBox(
          height: compact ? 7 : 9,
        ),

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 430,
          ),
          child: Text(
            'Idiomas, cultura y experiencias que te llevan más lejos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _LoginColors.slate.withOpacity(0.74),
              fontSize: compact ? 12.7 : 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactLogo extends StatelessWidget {
  const _CompactLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 155,
        child: Image.asset(
          'assets/art/brand/lingoverse_logo_full.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return const _FallbackLogo(
              compact: true,
            );
          },
        ),
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  final bool compact;

  const _FallbackLogo({
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Lingo',
            style: TextStyle(
              color: _LoginColors.navy,
              fontSize: compact ? 24 : 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(
            text: 'Verse',
            style: TextStyle(
              color: _LoginColors.gold,
              fontSize: compact ? 24 : 34,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _PremiumBackgroundPainter extends CustomPainter {
  final double t;

  const _PremiumBackgroundPainter({
    required this.t,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final rect = Offset.zero & size;

    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFEFB),
          Color(0xFFFAF7F1),
          Color(0xFFF3E9DB),
        ],
      ).createShader(rect);

    canvas.drawRect(
      rect,
      background,
    );

    final glowPaint = Paint()
      ..color = _LoginColors.gold.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        80,
      );

    canvas.drawCircle(
      Offset(
        size.width * 0.78,
        size.height * 0.12,
      ),
      size.width * 0.30,
      glowPaint,
    );

    final route = Path()
      ..moveTo(
        -40,
        size.height * 0.16,
      )
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.08,
        size.width * 0.70,
        size.height * 0.09,
        size.width + 40,
        size.height * 0.18,
      );

    canvas.drawPath(
      route,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _LoginColors.gold.withOpacity(0.11),
    );

    final metrics = route.computeMetrics().toList();

    if (metrics.isNotEmpty) {
      final metric = metrics.first;

      final tangent = metric.getTangentForOffset(
        metric.length * ((t * 0.65) % 1),
      );

      if (tangent != null) {
        final point = tangent.position;

        final planePaint = Paint()
          ..color = _LoginColors.gold.withOpacity(0.36)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(
            point.dx - 7,
            point.dy + 3,
          ),
          Offset(
            point.dx + 8,
            point.dy - 3,
          ),
          planePaint,
        );

        canvas.drawLine(
          Offset(
            point.dx + 2,
            point.dy - 2,
          ),
          Offset(
            point.dx + 7,
            point.dy + 4,
          ),
          planePaint,
        );
      }
    }

    final detailPaint = Paint()
      ..color = _LoginColors.gold.withOpacity(0.08);

    for (int i = 0; i < 12; i++) {
      final x = size.width *
          ((i * 0.181 + t * 0.004) % 1);

      final y = size.height *
          (0.05 + ((i * 0.227) % 0.88));

      canvas.drawCircle(
        Offset(x, y),
        i % 4 == 0 ? 1.1 : 0.6,
        detailPaint,
      );
    }

    _drawCompass(
      canvas,
      size,
    );
  }

  void _drawCompass(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width * 0.91,
      size.height * 0.72,
    );

    final radius = math.min(
          size.width,
          size.height,
        ) *
        0.08;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _LoginColors.navy.withOpacity(0.018);

    canvas.drawCircle(
      center,
      radius,
      paint,
    );

    canvas.drawCircle(
      center,
      radius * 0.55,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _PremiumBackgroundPainter oldDelegate,
  ) {
    return oldDelegate.t != t;
  }
}

abstract final class _LoginColors {
  static const Color ivory =
      Color(0xFFFAF7F1);

  static const Color navy =
      Color(0xFF102A43);

  static const Color slate =
      Color(0xFF627D98);

  static const Color gold =
      Color(0xFFD9A441);
}