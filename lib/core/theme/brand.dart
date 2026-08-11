import 'package:flutter/material.dart';

class Brand {
  Brand._();

  // ============================================================
  // PALETA OFICIAL
  // Usamos únicamente la identidad visual definida:
  // Sistema visual unificado con Login y Home: marfil, navy y dorado.
  // ============================================================

  static const Color bgDeep = Color(0xFF081D30);
  static const Color bgPanel = Color(0xFF102A43);
  static const Color purple = Color(0xFFD9A441);
  static const Color navy = Color(0xFF102A43);
  static const Color cyan = Color(0xFFEBC66E);
  static const Color mint = Color(0xFFEBC66E);
  static const Color mintDark = Color(0xFFA97320);

  // Neutros funcionales para lectura.
  static const Color white = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFD8C9B5);

  // Líneas y superficies derivadas del sistema visual.
  static const Color line = Color(0xFF29425C);
  static const Color field = Color(0xFF0D2438);
  static const Color card = Color(0xFF122F49);

  // Alias temporal para evitar errores si algún archivo viejo lo usa.
  // No usar como color principal en pantallas nuevas.
  static const Color yellow = mint;

  // ============================================================
  // RADIOS
  // ============================================================

  static const double radiusXs = 12;
  static const double radiusSm = 16;
  static const double radiusMd = 20;
  static const double radiusLg = 24;
  static const double radiusXl = 30;
  static const double radius2xl = 36;

  static BorderRadius get radiusCard => BorderRadius.circular(radiusXl);
  static BorderRadius get radiusPanel => BorderRadius.circular(radius2xl);
  static BorderRadius get radiusButton => BorderRadius.circular(22);
  static BorderRadius get radiusInput => BorderRadius.circular(21);
  static BorderRadius get radiusPill => BorderRadius.circular(999);

  // ============================================================
  // SOMBRAS
  // ============================================================

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.34),
          blurRadius: 28,
          spreadRadius: -8,
          offset: const Offset(0, 18),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.22),
          blurRadius: 22,
          spreadRadius: -10,
          offset: const Offset(0, 14),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.38),
          blurRadius: 34,
          spreadRadius: -8,
          offset: const Offset(0, 22),
        ),
      ];

  static List<BoxShadow> get glowMint => [
        BoxShadow(
          color: mint.withOpacity(0.24),
          blurRadius: 26,
          spreadRadius: -8,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: cyan.withOpacity(0.10),
          blurRadius: 42,
          spreadRadius: -12,
          offset: const Offset(0, 18),
        ),
      ];

  static List<BoxShadow> get glowCyan => [
        BoxShadow(
          color: cyan.withOpacity(0.18),
          blurRadius: 28,
          spreadRadius: -10,
          offset: const Offset(0, 14),
        ),
      ];

  static List<BoxShadow> get activeWorldShadow => [
        BoxShadow(
          color: mint.withOpacity(0.22),
          blurRadius: 34,
          spreadRadius: -10,
          offset: const Offset(0, 18),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.32),
          blurRadius: 28,
          spreadRadius: -12,
          offset: const Offset(0, 18),
        ),
      ];

  // ============================================================
  // BORDES
  // ============================================================

  static BorderSide get subtleBorder => BorderSide(
        color: white.withOpacity(0.10),
        width: 1,
      );

  static BorderSide get panelBorder => BorderSide(
        color: line.withOpacity(0.82),
        width: 1,
      );

  static BorderSide get activeBorder => BorderSide(
        color: mint.withOpacity(0.70),
        width: 1.4,
      );

  static BorderSide get cyanBorder => BorderSide(
        color: cyan.withOpacity(0.36),
        width: 1,
      );

  // ============================================================
  // DECORACIONES REUTILIZABLES
  // ============================================================

  static BoxDecoration get backgroundDecoration => const BoxDecoration(
        color: bgDeep,
      );

  static BoxDecoration panelDecoration({
    double opacity = 0.72,
    double radius = radiusXl,
    bool shadow = true,
    bool active = false,
  }) {
    return BoxDecoration(
      color: bgPanel.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: active ? mint.withOpacity(0.62) : white.withOpacity(0.10),
        width: active ? 1.4 : 1,
      ),
      boxShadow: shadow ? cardShadow : null,
    );
  }

  static BoxDecoration cardDecoration({
    double opacity = 0.62,
    double radius = radiusLg,
    bool active = false,
  }) {
    return BoxDecoration(
      color: card.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: active ? mint.withOpacity(0.65) : white.withOpacity(0.09),
        width: active ? 1.4 : 1,
      ),
      boxShadow: active ? activeWorldShadow : softShadow,
    );
  }

  static BoxDecoration inputDecoration({
    bool focused = false,
  }) {
    return BoxDecoration(
      color: field.withOpacity(0.76),
      borderRadius: radiusInput,
      border: Border.all(
        color: focused ? mint.withOpacity(0.58) : white.withOpacity(0.12),
        width: focused ? 1.35 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.18),
          blurRadius: 18,
          spreadRadius: -10,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  static BoxDecoration primaryButtonDecoration({
    bool pressed = false,
  }) {
    return BoxDecoration(
      color: pressed ? mintDark : mint,
      borderRadius: radiusButton,
      boxShadow: glowMint,
    );
  }

  static BoxDecoration outlineButtonDecoration() {
    return BoxDecoration(
      color: bgDeep.withOpacity(0.38),
      borderRadius: radiusButton,
      border: Border.all(
        color: mint.withOpacity(0.82),
        width: 1.2,
      ),
    );
  }

  static BoxDecoration chipDecoration({
    bool active = false,
  }) {
    return BoxDecoration(
      color: active ? mint : bgPanel.withOpacity(0.66),
      borderRadius: radiusPill,
      border: Border.all(
        color: active ? mint : white.withOpacity(0.10),
      ),
      boxShadow: active ? glowMint : null,
    );
  }

  // ============================================================
  // TEXTOS
  // ============================================================

  static TextStyle get logoLingoStyle => const TextStyle(
        color: white,
        fontWeight: FontWeight.w900,
        letterSpacing: -2.3,
        height: 1,
      );

  static TextStyle get logoVerseStyle => const TextStyle(
        color: mint,
        fontWeight: FontWeight.w900,
        letterSpacing: -2.3,
        height: 1,
      );

  static TextStyle get titleStyle => const TextStyle(
        color: white,
        fontSize: 30,
        height: 1.04,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
      );

  static TextStyle get subtitleStyle => TextStyle(
        color: muted.withOpacity(0.92),
        fontSize: 15.5,
        height: 1.35,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyStyle => TextStyle(
        color: white.withOpacity(0.78),
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get smallMutedStyle => TextStyle(
        color: white.withOpacity(0.48),
        fontSize: 12.5,
        height: 1.3,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get buttonTextStyle => const TextStyle(
        color: bgDeep,
        fontSize: 17,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.1,
      );

  static TextStyle get outlineButtonTextStyle => const TextStyle(
        color: mint,
        fontSize: 16.5,
        fontWeight: FontWeight.w900,
      );

  // ============================================================
  // HELPERS
  // ============================================================

  static Color textMuted([double opacity = 0.62]) {
    return white.withOpacity(opacity);
  }

  static Color panelColor([double opacity = 0.72]) {
    return bgPanel.withOpacity(opacity);
  }

  static Color lineColor([double opacity = 0.12]) {
    return white.withOpacity(opacity);
  }

  static Color mintColor([double opacity = 1]) {
    return mint.withOpacity(opacity);
  }

  static Color cyanColor([double opacity = 1]) {
    return cyan.withOpacity(opacity);
  }
}