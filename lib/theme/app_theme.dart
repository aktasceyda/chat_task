import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E3A8A), // Primary Blue
      background: const Color(0xFFF8FAFC), // Background Light
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8FAFC),
      scrolledUnderElevation: 0,
    ),
  );
}
