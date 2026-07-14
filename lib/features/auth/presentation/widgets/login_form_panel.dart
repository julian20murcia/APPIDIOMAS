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

  void _validateAndEnter(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showLoginMessage(
        context,
        'Completa tu correo y contraseña para iniciar la aventura.',
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Brand.bgPanel.withOpacity(0.96),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Brand.mint.withOpacity(0.28),
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
                      fontSize: 13.5,
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
      duration: const Duration(milliseconds: 720),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
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

          Row(
            children: [
              _SecurityHint(),
              const Spacer(),
              TextButton(
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          PrimaryButton(
            label: 'Iniciar aventura',
            icon: Icons.auto_awesome_rounded,
            onTap: () => _validateAndEnter(context),
            loading: loading,
          ),

          const SizedBox(height: 14),

          OutlinedBrandButton(
            label: 'Crear cuenta',
            onTap: () {},
          ),

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
      ),
    );
  }
}

class _SecurityHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.42),
        borderRadius: Brand.radiusPill,
        border: Border.all(
          color: Brand.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield_outlined,
            color: Brand.mint.withOpacity(0.88),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            'Acceso seguro',
            style: TextStyle(
              color: Brand.white.withOpacity(0.54),
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}