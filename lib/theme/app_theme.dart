import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF00A8E8),
    scaffoldBackgroundColor: const Color(0xFFE6FAF5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF007EA7),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: TextTheme(
      titleLarge: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF007EA7),
      ),
      bodyMedium: GoogleFonts.raleway(fontSize: 16, color: Color(0xFF333C4D)),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00A8E8),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF00A8E8),
      brightness: Brightness.light,
    ),
  );
}
