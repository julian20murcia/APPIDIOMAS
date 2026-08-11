import 'package:flutter/material.dart';

class LoginFormPanel extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final bool obscurePassword;
  final bool loading;
  final bool compact;

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
    this.compact = false,
  });

  void _validateAndEnter(
    BuildContext context,
  ) {
    final email =
        emailController.text.trim();

    final password =
        passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        context,
        'Completa tu correo y contraseña.',
      );
      return;
    }

    final validEmail = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    if (!validEmail) {
      _showMessage(
        context,
        'Ingresa un correo electrónico válido.',
      );
      return;
    }

    if (password.length < 6) {
      _showMessage(
        context,
        'La contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }

    onEnter();
  }

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    final messenger =
        ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              Colors.transparent,
          margin:
              const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            18,
          ),
          content: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: _FormColors.navy,
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: _FormColors.gold,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.4,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.sizeOf(context).width;

    final isCompact =
        compact || width < 370;

    final wide =
        width >= 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isCompact ? 20 : 24,
        isCompact ? 22 : 26,
        isCompact ? 20 : 24,
        isCompact ? 19 : 22,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius:
            BorderRadius.circular(
          wide ? 30 : 28,
        ),
        border: Border.all(
          color:
              _FormColors.navy.withOpacity(0.055),
        ),
        boxShadow: [
          BoxShadow(
            color:
                _FormColors.navy.withOpacity(0.08),
            blurRadius: 32,
            spreadRadius: -16,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -38,
            bottom: -38,
            child: IgnorePointer(
              child: Icon(
                Icons.explore_rounded,
                size: 145,
                color: _FormColors.navy.withOpacity(0.022),
              ),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: _FormColors.gold,
                      borderRadius:
                          BorderRadius.circular(999),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'CONTINÚA TU VIAJE',
                    style: TextStyle(
                      color: _FormColors.goldDark,
                      fontSize: isCompact ? 9 : 9.7,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: isCompact ? 12 : 14,
              ),

              Text(
                'Inicia sesión',
                style: TextStyle(
                  color: _FormColors.navy,
                  fontSize: isCompact ? 24 : 27,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),

              SizedBox(
                height: isCompact ? 6 : 8,
              ),

              Text(
                'Sigue aprendiendo desde donde lo dejaste.',
                style: TextStyle(
                  color: _FormColors.slate.withOpacity(0.70),
                  fontSize: isCompact ? 12.2 : 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(
                height: isCompact ? 18 : 21,
              ),

              _LoginInput(
                controller: emailController,
                icon: Icons.mail_outline_rounded,
                hint: 'Correo electrónico',
                keyboardType:
                    TextInputType.emailAddress,
                textInputAction:
                    TextInputAction.next,
                autofillHints: const [
                  AutofillHints.email,
                ],
                compact: isCompact,
              ),

              SizedBox(
                height: isCompact ? 10 : 12,
              ),

              _LoginInput(
                controller: passwordController,
                icon: Icons.lock_outline_rounded,
                hint: 'Contraseña',
                obscureText: obscurePassword,
                trailing: obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                onTrailingTap:
                    onTogglePassword,
                textInputAction:
                    TextInputAction.done,
                autofillHints: const [
                  AutofillHints.password,
                ],
                onSubmitted: (_) {
                  _validateAndEnter(context);
                },
                compact: isCompact,
              ),

              SizedBox(
                height: isCompact ? 4 : 5,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 6,
                    ),
                  ),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: _FormColors.goldDark,
                      fontSize: isCompact ? 11.2 : 11.7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: isCompact ? 11 : 14,
              ),

              _LoginButton(
                compact: isCompact,
                loading: loading,
                onTap: () {
                  _validateAndEnter(context);
                },
              ),

              SizedBox(
                height: isCompact ? 14 : 16,
              ),

              Center(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    padding:
                        const EdgeInsets.all(3),
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: _FormColors.slate.withOpacity(0.65),
                        fontSize: isCompact ? 12.1 : 12.7,
                        fontWeight: FontWeight.w500,
                      ),
                      children: const [
                        TextSpan(
                          text: '¿Aún no tienes cuenta? ',
                        ),
                        TextSpan(
                          text: 'Crear cuenta',
                          style: TextStyle(
                            color: _FormColors.navy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: isCompact ? 12 : 14,
              ),

              Center(
                child: Text(
                  'Tu progreso se guarda automáticamente.',
                  style: TextStyle(
                    color: _FormColors.slate.withOpacity(0.42),
                    fontSize: isCompact ? 9.8 : 10.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoginInput extends StatefulWidget {
  final TextEditingController controller;

  final IconData icon;
  final String hint;

  final bool compact;
  final bool obscureText;

  final IconData? trailing;
  final VoidCallback? onTrailingTap;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  const _LoginInput({
    required this.controller,
    required this.icon,
    required this.hint,
    required this.compact,
    this.obscureText = false,
    this.trailing,
    this.onTrailingTap,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
  });

  @override
  State<_LoginInput> createState() =>
      _LoginInputState();
}

class _LoginInputState extends State<_LoginInput> {
  late final FocusNode _focusNode;

  bool focused = false;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocus);
  }

  void _handleFocus() {
    if (!mounted) return;

    setState(() {
      focused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      height: widget.compact ? 52 : 56,
      decoration: BoxDecoration(
        color: _FormColors.cream,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: focused
              ? _FormColors.gold
              : _FormColors.navy.withOpacity(0.055),
          width: focused ? 1.35 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: _FormColors.gold.withOpacity(0.09),
                  blurRadius: 18,
                  spreadRadius: -9,
                  offset: const Offset(0, 9),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: widget.compact ? 14 : 16,
          ),

          Icon(
            widget.icon,
            color: focused
                ? _FormColors.goldDark
                : _FormColors.slate.withOpacity(0.64),
            size: widget.compact ? 19 : 20,
          ),

          SizedBox(
            width: widget.compact ? 10 : 11,
          ),

          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              autofillHints: widget.autofillHints,
              autocorrect: false,
              enableSuggestions: !widget.obscureText,
              onSubmitted: widget.onSubmitted ??
                  (_) {
                    if (widget.textInputAction ==
                        TextInputAction.next) {
                      FocusScope.of(context).nextFocus();
                    }
                  },
              cursorColor: _FormColors.goldDark,
              style: TextStyle(
                color: _FormColors.navy,
                fontSize: widget.compact ? 14 : 14.7,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: _FormColors.slate.withOpacity(0.40),
                  fontSize: widget.compact ? 13 : 13.6,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          if (widget.trailing != null)
            IconButton(
              onPressed: widget.onTrailingTap,
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 42,
                minHeight: 42,
              ),
              icon: Icon(
                widget.trailing,
                color: _FormColors.slate.withOpacity(0.58),
                size: 20,
              ),
            )
          else
            const SizedBox(width: 14),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool compact;
  final bool loading;
  final VoidCallback onTap;

  const _LoginButton({
    required this.compact,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 53 : 56,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius:
            BorderRadius.circular(16),
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius:
              BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  _FormColors.navy,
                  _FormColors.navyDeep,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _FormColors.navy.withOpacity(0.18),
                  blurRadius: 20,
                  spreadRadius: -10,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: 180),
                child: loading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                            _FormColors.gold,
                          ),
                        ),
                      )
                    : Row(
                        key: const ValueKey('content'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continuar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  compact ? 15.5 : 16.3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(width: 13),

                          Container(
                            width: compact ? 30 : 32,
                            height: compact ? 30 : 32,
                            decoration: const BoxDecoration(
                              color: _FormColors.gold,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: _FormColors.navyDeep,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class _FormColors {
  static const Color navy =
      Color(0xFF102A43);

  static const Color navyDeep =
      Color(0xFF081D30);

  static const Color slate =
      Color(0xFF627D98);

  static const Color gold =
      Color(0xFFD9A441);

  static const Color goldDark =
      Color(0xFFA97320);

  static const Color cream =
      Color(0xFFFAF7F1);
}