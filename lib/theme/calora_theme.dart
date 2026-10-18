import 'package:flutter/material.dart';

/// Palette from the Calora design spec (DESIGN.md §2), shared with the web app.
class CaloraColors {
  static const forest = Color(0xFF18542A);
  static const carrot = Color(0xFFF96015);
  static const carrotDeep = Color(0xFFE04F09);
  static const cream = Color(0xFFF3E8CC);
  static const canvas = Color(0xFFFAFAF5);
  static const charcoal = Color(0xFF1C1E1B);
  static const mutedGreen = Color(0xFF5C6B5E);
  static const kiwi = Color(0xFF9ABC05);
  static const sunshine = Color(0xFFFFC926);
  static const tomato = Color(0xFFD52518);
  static const matcha = Color(0xFF0D3A1F);

  static const bg = canvas;
  static const surface = canvas;
  static const ink = charcoal;
  static const inkMuted = mutedGreen;
  static const inkFaint = mutedGreen;
  static const heading = forest;
  static const accent = carrot;
  static const orange = carrot;
  static const success = forest;
  static const danger = tomato;
  static const nav = forest;
  static const navInk = cream;

  static const protein = kiwi;
  static const carbs = sunshine;
  static const fat = carrot;
}

/// Oswald for display text (always uppercase the string), Inter for everything else.
class CaloraText {
  static const display = 'Oswald';
  static const body = 'Inter';

  /// H1: 32px bold, forest.
  static const title = TextStyle(fontFamily: display, fontSize: 32, fontWeight: FontWeight.w700, color: CaloraColors.heading, height: 1.1);

  /// H2: 22px semibold, forest.
  static const section = TextStyle(fontFamily: display, fontSize: 22, fontWeight: FontWeight.w600, color: CaloraColors.heading, height: 1.15);

  /// Big numbers on cards.
  static TextStyle stat(double size) =>
      TextStyle(fontFamily: display, fontSize: size, fontWeight: FontWeight.w700, color: CaloraColors.ink, height: 1);

  /// Small uppercase-style labels and metric subtitles: 12px medium, muted green.
  static const micro = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: CaloraColors.inkMuted, letterSpacing: 0.4);
}

const caloraShadow = BoxShadow(color: Color(0x1418542A), blurRadius: 20, offset: Offset(0, 6));

ThemeData caloraTheme() {
  const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: CaloraColors.cream, width: 1),
  );
  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
  return ThemeData(
    useMaterial3: true,
    fontFamily: CaloraText.body,
    scaffoldBackgroundColor: CaloraColors.bg,
    colorScheme: const ColorScheme.light(
      primary: CaloraColors.accent,
      onPrimary: Colors.white,
      secondary: CaloraColors.forest,
      onSecondary: Colors.white,
      surface: CaloraColors.surface,
      onSurface: CaloraColors.ink,
      error: CaloraColors.danger,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: CaloraColors.ink),
      bodyLarge: TextStyle(color: CaloraColors.ink),
      titleLarge: TextStyle(fontFamily: CaloraText.display, color: CaloraColors.heading, fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: CaloraColors.heading,
      elevation: 0,
      titleTextStyle: TextStyle(fontFamily: CaloraText.display, fontSize: 22, fontWeight: FontWeight.w600, color: CaloraColors.heading),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CaloraColors.cream.withValues(alpha: 0.45),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(borderSide: const BorderSide(color: CaloraColors.forest, width: 1.4)),
      labelStyle: const TextStyle(color: CaloraColors.inkMuted),
    ),
    // Primary action: carrot, deepening when pressed.
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return CaloraColors.carrot.withValues(alpha: 0.5);
          if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) return CaloraColors.carrotDeep;
          return CaloraColors.carrot;
        }),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
        shape: WidgetStatePropertyAll(buttonShape),
        textStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: CaloraText.body, fontWeight: FontWeight.w600, fontSize: 15)),
      ),
    ),
    // Secondary action: cream fill, forest text.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: CaloraColors.cream,
        foregroundColor: CaloraColors.forest,
        side: BorderSide.none,
        minimumSize: const Size.fromHeight(48),
        shape: buttonShape,
        textStyle: const TextStyle(fontFamily: CaloraText.body, fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: CaloraColors.forest, shape: buttonShape)),
    chipTheme: ChipThemeData(backgroundColor: CaloraColors.cream, selectedColor: CaloraColors.carrot, shape: buttonShape, side: BorderSide.none),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: CaloraColors.carrot, linearTrackColor: CaloraColors.cream),
    snackBarTheme: const SnackBarThemeData(backgroundColor: CaloraColors.forest, contentTextStyle: TextStyle(color: CaloraColors.cream)),
  );
}
