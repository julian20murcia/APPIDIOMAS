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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 18,
        compact ? 18 : 20,
        compact ? 16 : 18,
        compact ? 16 : 18,
      ),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.64),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: Brand.white.withOpacity(0.115),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.32),
            blurRadius: 34,
            spreadRadius: -14,
            offset: const Offset(0, 22),
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
              color: Brand.white.withOpacity(0.96),
              fontSize: compact ? 20 : 22,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: compact ? 16 : 18),

          _GameInput(
            controller: emailController,
            icon: Icons.mail_outline_rounded,
            hint: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            compact: compact,
          ),

          SizedBox(height: compact ? 11 : 13),

          _GameInput(
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

          SizedBox(height: compact ? 8 : 10),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: Brand.mint,
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: Brand.mint,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          SizedBox(height: compact ? 12 : 14),

          _GamePrimaryButton(
            loading: loading,
            compact: compact,
            onTap: () => _validateAndEnter(context),
          ),

          SizedBox(height: compact ? 12 : 14),

          _CreateAccountRow(onTap: () {}),
        ],
      ),
    );
  }
}

class _GameInput extends StatelessWidget {
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

  const _GameInput({
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
      height: compact ? 52 : 56,
      decoration: BoxDecoration(
        color: Brand.bgDeep.withOpacity(0.48),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Brand.white.withOpacity(0.13),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),

          Icon(
            icon,
            color: Brand.white.withOpacity(0.68),
            size: 22,
          ),

          const SizedBox(width: 13),

          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              cursorColor: Brand.mint,
              style: const TextStyle(
                color: Brand.white,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Brand.white.withOpacity(0.42),
                  fontSize: 14.6,
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
              icon: Icon(
                trailing,
                color: Brand.white.withOpacity(0.68),
                size: 22,
              ),
            )
          else
            const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _GamePrimaryButton extends StatelessWidget {
  final bool loading;
  final bool compact;
  final VoidCallback onTap;

  const _GamePrimaryButton({
    required this.loading,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: loading ? null : onTap,
        child: Container(
          height: compact ? 56 : 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Brand.mint,
            borderRadius: BorderRadius.circular(23),
            boxShadow: [
              BoxShadow(
                color: Brand.mint.withOpacity(0.35),
                blurRadius: 26,
                spreadRadius: -8,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: loading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Brand.bgDeep,
                        ),
                      ),
                    )
                  : Row(
                      key: const ValueKey('label'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: Brand.bgDeep,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Brand.bgDeep.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.sports_esports_rounded,
                            color: Brand.bgDeep,
                            size: 22,
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
  final VoidCallback onTap;

  const _CreateAccountRow({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Brand.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            color: Brand.white.withOpacity(0.68),
            fontSize: 14,
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