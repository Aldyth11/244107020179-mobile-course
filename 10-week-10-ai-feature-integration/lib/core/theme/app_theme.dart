import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color scaffoldBg = Color(0xFFF8FAFC);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: accentBlue,
        ),
        scaffoldBackgroundColor: scaffoldBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0.5,
        ),
      );
}
