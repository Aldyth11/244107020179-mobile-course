import 'package:flutter/material.dart';

/// Hallmark Design System - Cobalt Token Architecture
abstract class AppTokens {
  // Surfaces & Backgrounds
  static const Color paper = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  // Typography & Ink
  static const Color ink = Color(0xFF0F172A);
  static const Color inkMuted = Color(0xFF64748B);
  static const Color inkFaint = Color(0xFF94A3B8);

  // Borders & Hairlines
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocused = Color(0xFF93C5FD);

  // Cobalt Accents
  static const Color accent = Color(0xFF2563EB);
  static const Color accentDeep = Color(0xFF1D4ED8);
  static const Color accentWash = Color(0xFFEFF6FF);
  static const Color accentBorder = Color(0xFFBFDBFE);

  // Semantic Colors
  static const Color success = Color(0xFF059669);
  static const Color successWash = Color(0xFFECFDF5);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerWash = Color(0xFFFEF2F2);
  static const Color dangerBorder = Color(0xFFFECACA);

  // Dimensions & Radiuses
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 10.0;
  static const double radiusLarge = 14.0;
  static const double radiusPill = 999.0;
}

