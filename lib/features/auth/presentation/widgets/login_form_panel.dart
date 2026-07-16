import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

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

  void _validateAndEnter(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showLoginMessage(
        context,
        'Completa tu correo y contraseña para continuar.',
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showLoginMessage(
        context,
        'Ingresa un correo electrónico válido.',
      );
      return;
    }

    if (password.length < 6) {
      _showLoginMessage(
        context,
        'La contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }

    onEnter();
  }

  void _showLoginMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: BoxDecoration(
              color: Brand.bgPanel.withOpacity(0.96),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Brand.mint.withOpacity(0.30),
              ),
              boxShadow: Brand.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Brand.mint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Brand.bgDeep,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Brand.white,
                      fontSize: 13.2,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 20,
          compact ? 18 : 22,
          compact ? 16 : 20,
          compact ? 16 : 18,
        ),
        decoration: BoxDecoration(
          color: Brand.bgPanel.withOpacity(0.70),
          borderRadius: BorderRadius.circular(compact ? 28 : 34),
          border: Border.all(
            color: Brand.white.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 28,
              spreadRadius: -17,
              offset: const Offset(0, 19),
            ),
            BoxShadow(
              color: Brand.cyan.withOpacity(0.04),
              blurRadius: 36,
              spreadRadius: -22,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡Bienvenido de nuevo!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Brand.white,
                fontSize: compact ? 20 : 24,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.45,
              ),
            ),
            SizedBox(height: compact ? 6 : 8),
            Text(
              'Inicia sesión para continuar tu aventura.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Brand.white.withOpacity(0.60),
                fontSize: compact ? 12.3 : 13.8,
                height: 1.18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: compact ? 16 : 18),
            _LoginInput(
              controller: emailController,
              icon: Icons.mail_outline_rounded,
              hint: 'Correo electrónico',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              compact: compact,
            ),
            SizedBox(height: compact ? 11 : 12),
            _LoginInput(
              controller: passwordController,
              icon: Icons.lock_outline_rounded,
              hint: 'Contraseña',
              obscureText: obscurePassword,
              trailing: obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              onTrailingTap: onTogglePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _validateAndEnter(context),
              compact: compact,
            ),
            SizedBox(height: compact ? 7 : 9),
            Align(
              alignment: Alignment.centerRight,
              child: _ForgotPasswordButton(
                compact: compact,
                onTap: () {},
              ),
            ),
            SizedBox(height: compact ? 13 : 15),
            _PrimaryLoginButton(
              loading: loading,
              compact: compact,
              onTap: () => _validateAndEnter(context),
            ),
            SizedBox(height: compact ? 10 : 12),
            _CreateAccountRow(
              compact: compact,
              onTap: () {},
            ),
            if (!compact) ...[
              const SizedBox(height: 16),
              const _SocialDivider(),
              const SizedBox(height: 14),
              const _SocialRow(showLabels: true),
              const SizedBox(height: 16),
              const _TermsText(),
            ] else ...[
              const SizedBox(height: 8),
              const _CompactTermsText(),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoginInput extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 50 : 56,
      decoration: BoxDecoration(
        color: Brand.bgDeep.withOpacity(0.42),
        borderRadius: BorderRadius.circular(compact ? 17 : 19),
        border: Border.all(
          color: Brand.white.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: compact ? 14 : 16),
          Icon(
            icon,
            color: Brand.white.withOpacity(0.72),
            size: compact ? 21 : 22,
          ),
          SizedBox(width: compact ? 11 : 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              cursorColor: Brand.mint,
              style: TextStyle(
                color: Brand.white,
                fontSize: compact ? 15 : 15.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.12,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Brand.white.withOpacity(0.40),
                  fontSize: compact ? 14 : 14.5,
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (trailing != null)
            IconButton(
              onPressed: onTrailingTap,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: compact ? 40 : 42,
                minHeight: compact ? 40 : 42,
              ),
              icon: Icon(
                trailing,
                color: Brand.white.withOpacity(0.72),
                size: compact ? 21 : 22,
              ),
            )
          else
            SizedBox(width: compact ? 14 : 16),
        ],
      ),
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  final bool compact;
  final VoidCallback onTap;

  const _ForgotPasswordButton({
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Brand.mint,
        padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: compact ? 2 : 4,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        '¿Olvidaste tu contraseña?',
        style: TextStyle(
          color: Brand.mint,
          fontSize: compact ? 12.4 : 12.8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PrimaryLoginButton extends StatelessWidget {
  final bool loading;
  final bool compact;
  final VoidCallback onTap;

  const _PrimaryLoginButton({
    required this.loading,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(compact ? 22 : 24),
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 22 : 24),
        onTap: loading ? null : onTap,
        child: Container(
          height: compact ? 56 : 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Brand.mint,
            borderRadius: BorderRadius.circular(compact ? 22 : 24),
            boxShadow: [
              BoxShadow(
                color: Brand.mint.withOpacity(0.30),
                blurRadius: 22,
                spreadRadius: -10,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: loading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Brand.bgDeep,
                        ),
                      ),
                    )
                  : Row(
                      key: const ValueKey('label'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: Brand.bgDeep,
                            fontSize: compact ? 17.5 : 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: compact ? 34 : 36,
                          height: compact ? 34 : 36,
                          decoration: BoxDecoration(
                            color: Brand.bgDeep.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            Icons.sports_esports_rounded,
                            color: Brand.bgDeep,
                            size: compact ? 21 : 22,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateAccountRow extends StatelessWidget {
  final bool compact;
  final VoidCallback onTap;

  const _CreateAccountRow({
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Brand.white,
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: compact ? 1 : 3,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            color: Brand.white.withOpacity(0.68),
            fontSize: compact ? 13.4 : 13.8,
            fontWeight: FontWeight.w700,
          ),
          children: const [
            TextSpan(text: '¿No tienes cuenta? '),
            TextSpan(
              text: 'Crea una',
              style: TextStyle(
                color: Brand.mint,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialDivider extends StatelessWidget {
  const _SocialDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Brand.white.withOpacity(0.14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Text(
            'o continúa con',
            style: TextStyle(
              color: Brand.white.withOpacity(0.62),
              fontSize: 12.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Brand.white.withOpacity(0.14),
          ),
        ),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  final bool showLabels;

  const _SocialRow({
    required this.showLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: showLabels ? 'Google' : '',
            symbol: 'G',
            backgroundColor: Brand.white.withOpacity(0.95),
            foregroundColor: Brand.bgDeep,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialButton(
            label: showLabels ? 'Facebook' : '',
            symbol: 'f',
            backgroundColor: const Color(0xFF1266F1),
            foregroundColor: Brand.white,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialButton(
            label: showLabels ? 'Apple' : '',
            symbol: '',
            backgroundColor: const Color(0xFF191919),
            foregroundColor: Brand.white,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String symbol;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.symbol,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onlyIcon = label.trim().isEmpty;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(
            horizontal: onlyIcon ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 17,
                spreadRadius: -11,
                offset: const Offset(0, 11),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                symbol,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: onlyIcon ? 22 : 20,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              if (!onlyIcon) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.shield_outlined,
          color: Brand.mint.withOpacity(0.90),
          size: 19,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                color: Brand.white.withOpacity(0.56),
                height: 1.30,
                fontSize: 11.7,
                fontWeight: FontWeight.w600,
              ),
              children: const [
                TextSpan(text: 'Al continuar, aceptas nuestros '),
                TextSpan(
                  text: 'Términos',
                  style: TextStyle(
                    color: Brand.mint,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(text: ' y '),
                TextSpan(
                  text: 'Política de privacidad',
                  style: TextStyle(
                    color: Brand.mint,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactTermsText extends StatelessWidget {
  const _CompactTermsText();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: Brand.white.withOpacity(0.46),
          fontSize: 11.4,
          height: 1.16,
          fontWeight: FontWeight.w600,
        ),
        children: const [
          TextSpan(text: 'Aceptas nuestros '),
          TextSpan(
            text: 'Términos',
            style: TextStyle(
              color: Brand.mint,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(text: ' y '),
          TextSpan(
            text: 'Privacidad',
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