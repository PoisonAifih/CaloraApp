import 'package:flutter/material.dart';

class CaloraColors {
  static const bg = Color(0xFF7EB85F);
  static const surface = Color(0xFFFFF6EA);
  static const ink = Color(0xFF3A2A1A);
  static const inkMuted = Color(0xFF6B5344);
  static const inkFaint = Color(0xFF8A7564);
  static const accent = Color(0xFFE24B32);
  static const orange = Color(0xFFE07A2F);
  static const success = Color(0xFF2F7D4A);
  static const navInk = Color(0xFFF6F0DC);
}

ThemeData caloraTheme() {
  const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: CaloraColors.ink, width: 1.4),
  );
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: CaloraColors.bg,
    colorScheme: const ColorScheme.light(
      primary: CaloraColors.accent,
      onPrimary: Colors.white,
      secondary: CaloraColors.orange,
      surface: CaloraColors.surface,
      onSurface: CaloraColors.ink,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: CaloraColors.ink),
      bodyLarge: TextStyle(color: CaloraColors.ink),
      titleLarge: TextStyle(color: CaloraColors.ink, fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      labelStyle: TextStyle(color: CaloraColors.inkMuted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: CaloraColors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
