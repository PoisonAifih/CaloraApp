import 'package:flutter/material.dart';

/// Palette from the Calora design spec (DESIGN.md §2), shared with the web app.
///
/// Colours are getters so the whole app can switch between light and dark:
/// [CaloraApp] sets [dark] and rebuilds every widget when the theme changes.
class CaloraColors {
  static bool dark = false;

  static Color _pick(int light, int night) => Color(dark ? night : light);

  /// Brand green used as a background (cards, badges, avatar).
  static Color get forest => _pick(0xFF18542A, 0xFF1F4D2C);

  /// Text and icons placed on [forest].
  static Color get onForest => _pick(0xFFF3E8CC, 0xFFEEF3E6);
  static Color get carrot => const Color(0xFFF96015);
  static Color get carrotDeep => _pick(0xFFE04F09, 0xFFFF7A33);

  /// Soft fill for chips, tracks and inputs.
  static Color get cream => _pick(0xFFF3E8CC, 0xFF262C23);
  static Color get canvas => _pick(0xFFFAFAF5, 0xFF121511);
  static Color get charcoal => _pick(0xFF1C1E1B, 0xFFECEBE2);
  static Color get mutedGreen => _pick(0xFF5C6B5E, 0xFFA3AF9F);
  static Color get kiwi => _pick(0xFF9ABC05, 0xFFA9CC1A);
  static Color get sunshine => const Color(0xFFFFC926);
  static Color get tomato => _pick(0xFFD52518, 0xFFFF6B5B);
  static Color get matcha => _pick(0xFF0D3A1F, 0xFF2C6B3D);

  /// Outline for pills and secondary buttons.
  static Color get sand => _pick(0xFFE4D6B1, 0xFF353C30);
  static Color get okSoft => _pick(0xFFDFEEDD, 0xFF1F3A26);
  static Color get warnSoft => _pick(0xFFFBE3DF, 0xFF4A201B);

  /// Area behind the login card.
  static Color get backdrop => _pick(0xFFE6EADC, 0xFF0B0D0A);

  static Color get bg => canvas;
  static Color get surface => canvas;
  static Color get ink => charcoal;
  static Color get inkMuted => mutedGreen;
  static Color get inkFaint => mutedGreen;

  /// Green used for headings, links and icons on the page background.
  static Color get heading => _pick(0xFF18542A, 0xFF8FD19E);
  static Color get accent => carrot;
  static Color get orange => carrot;
  static Color get success => heading;
  static Color get danger => tomato;
  static Color get nav => forest;
  static Color get navInk => onForest;

  static Color get protein => kiwi;
  static Color get carbs => sunshine;
  static Color get fat => carrot;
}

/// Oswald for display text (always uppercase the string), Inter for everything else.
class CaloraText {
  static const display = 'Oswald';
  static const body = 'Inter';

  /// H1: 32px bold, forest.
  static TextStyle get title => TextStyle(fontFamily: display, fontSize: 32, fontWeight: FontWeight.w700, color: CaloraColors.heading, height: 1.1);

  /// H2: 22px semibold, forest.
  static TextStyle get section => TextStyle(fontFamily: display, fontSize: 22, fontWeight: FontWeight.w600, color: CaloraColors.heading, height: 1.15);

  /// Big numbers on cards.
  static TextStyle stat(double size) =>
      TextStyle(fontFamily: display, fontSize: size, fontWeight: FontWeight.w700, color: CaloraColors.ink, height: 1);

  /// Small uppercase-style labels and metric subtitles: 12px medium, muted green.
  static TextStyle get micro => TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: CaloraColors.inkMuted, letterSpacing: 0.4);
}

BoxShadow get caloraShadow => BoxShadow(color: CaloraColors.dark ? const Color(0x59000000) : const Color(0x1418542A), blurRadius: 20, offset: const Offset(0, 6));

ThemeData caloraTheme() {
  final dark = CaloraColors.dark;
  final border = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: CaloraColors.cream, width: 1),
  );
  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
  return ThemeData(
    useMaterial3: true,
    fontFamily: CaloraText.body,
    scaffoldBackgroundColor: CaloraColors.bg,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: (dark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
      primary: CaloraColors.accent,
      onPrimary: Colors.white,
      secondary: CaloraColors.forest,
      onSecondary: CaloraColors.onForest,
      surface: CaloraColors.surface,
      onSurface: CaloraColors.ink,
      error: CaloraColors.danger,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: CaloraColors.ink),
      bodyLarge: TextStyle(color: CaloraColors.ink),
      titleLarge: TextStyle(fontFamily: CaloraText.display, color: CaloraColors.heading, fontWeight: FontWeight.w700),
    ),
    appBarTheme: AppBarTheme(
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
      focusedBorder: border.copyWith(borderSide: BorderSide(color: CaloraColors.heading, width: 1.4)),
      labelStyle: TextStyle(color: CaloraColors.inkMuted),
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
    // Secondary action: cream fill, green text.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: CaloraColors.cream,
        foregroundColor: CaloraColors.heading,
        side: BorderSide.none,
        minimumSize: const Size.fromHeight(48),
        shape: buttonShape,
        textStyle: const TextStyle(fontFamily: CaloraText.body, fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: CaloraColors.heading, shape: buttonShape)),
    chipTheme: ChipThemeData(backgroundColor: CaloraColors.cream, selectedColor: CaloraColors.carrot, shape: buttonShape, side: BorderSide.none),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: CaloraColors.carrot, linearTrackColor: CaloraColors.cream),
    snackBarTheme: SnackBarThemeData(backgroundColor: CaloraColors.forest, contentTextStyle: TextStyle(color: CaloraColors.onForest)),
  );
}
