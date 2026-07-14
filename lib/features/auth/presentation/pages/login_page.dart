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
  late final AnimationController _entryCtrl;
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

    _pageController = PageController(
      viewportFraction: 0.62,
      initialPage: 0,
    );

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1650),
    )..repeat(reverse: true);

    _emailController = TextEditingController(text: 'estudiante@app.com');
    _passwordController = TextEditingController(text: '123456');

    _startWorldAutoPlay();
  }

  void _startWorldAutoPlay() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return false;

      final next = (current + 1) % worlds.length;

      if (_pageController.hasClients) {
        await _pageController.animateToPage(
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
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
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
        transitionDuration: const Duration(milliseconds: 760),
        reverseTransitionDuration: const Duration(milliseconds: 420),
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

    final isSmall = height < 760;
    final currentWorld = worlds[current];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _entryCtrl,
          _floatCtrl,
          _pulseCtrl,
        ]),
        builder: (context, _) {
          final entry = Curves.easeOutCubic.transform(_entryCtrl.value);

          return Stack(
            children: [
              const LearningBackground(),

              Positioned.fill(
                child: CustomPaint(
                  painter: LearningMotifPainter(t: _floatCtrl.value),
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
                        isSmall ? 12 : 18,
                        22,
                        bottom + keyboard + 20,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight -
                              bottom -
                              keyboard -
                              (isSmall ? 12 : 18),
                        ),
                        child: Transform.translate(
                          offset: Offset(0, 24 * (1 - entry)),
                          child: Opacity(
                            opacity: entry,
                            child: Column(
                              children: [
                                SizedBox(height: isSmall ? 4 : 12),

                                const LoginHeader(),

                                SizedBox(height: isSmall ? 18 : 24),

                                LoginWorldCarousel(
                                  pageController: _pageController,
                                  current: current,
                                  floatValue: _floatCtrl.value,
                                  onChanged: (i) {
                                    if (current == i) return;
                                    setState(() => current = i);
                                  },
                                ),

                                const SizedBox(height: 10),

                                LoginDots(
                                  current: current,
                                  total: worlds.length,
                                ),

                                SizedBox(height: isSmall ? 14 : 18),

                                _ActiveWorldInfoCard(
                                  language: currentWorld.language,
                                  city: currentWorld.city,
                                  flag: currentWorld.flag,
                                  hello: currentWorld.hello,
                                  subtitle: currentWorld.safeSubtitle,
                                  hint: currentWorld.safeLoginHint,
                                  pulse: _pulseCtrl.value,
                                ),

                                SizedBox(height: isSmall ? 18 : 24),

                                LoginFormPanel(
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  obscurePassword: obscurePassword,
                                  loading: loading,
                                  onTogglePassword: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                  onEnter: _enter,
                                ),

                                SizedBox(height: isSmall ? 14 : 18),

                                const _LoginTerms(),

                                SizedBox(height: isSmall ? 8 : 12),
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

class _ActiveWorldInfoCard extends StatelessWidget {
  final String language;
  final String city;
  final String flag;
  final String hello;
  final String subtitle;
  final String hint;
  final double pulse;

  const _ActiveWorldInfoCard({
    required this.language,
    required this.city,
    required this.flag,
    required this.hello,
    required this.subtitle,
    required this.hint,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey('$language-$city'),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: Brand.cardDecoration(
          opacity: 0.48,
          radius: Brand.radiusLg,
          active: true,
        ).copyWith(
          boxShadow: [
            BoxShadow(
              color: Brand.mint.withOpacity(0.10 + pulse * 0.08),
              blurRadius: 28,
              spreadRadius: -12,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Brand.bgDeep.withOpacity(0.64),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Brand.white.withOpacity(0.10),
                ),
              ),
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$language · $city',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Brand.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hint.isNotEmpty ? hint : subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Brand.white.withOpacity(0.58),
                      fontSize: 12.7,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Brand.mint,
                borderRadius: Brand.radiusPill,
                boxShadow: Brand.glowMint,
              ),
              child: Text(
                hello,
                style: const TextStyle(
                  color: Brand.bgDeep,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginTerms extends StatelessWidget {
  const _LoginTerms();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: Brand.white.withOpacity(0.50),
          height: 1.45,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        children: const [
          TextSpan(
            text: 'Al continuar, aceptas nuestros Términos y\n',
          ),
          TextSpan(
            text: 'Política de privacidad',
            style: TextStyle(
              color: Brand.mint,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}