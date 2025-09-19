import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Green color scheme matching the original design
  static const Color primaryGreen = Color(0xFF15803D);  // --primary
  static const Color secondaryGreen = Color(0xFF84CC16); // --secondary
  static const Color lightGreen = Color(0xFFF0FDF4);    // --card
  static const Color darkGray = Color(0xFF374151);      // --foreground

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: _createMaterialColor(primaryGreen),
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryGreen,
      surface: lightGreen,
      background: Colors.white,
      onBackground: darkGray,
      onSurface: darkGray,
    ),
    textTheme: GoogleFonts.merriweatherTextTheme().copyWith(
      displayLarge: GoogleFonts.merriweather(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: primaryGreen,
      ),
      displayMedium: GoogleFonts.merriweather(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: primaryGreen,
      ),
      displaySmall: GoogleFonts.merriweather(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primaryGreen,
      ),
      headlineLarge: GoogleFonts.merriweather(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: darkGray,
      ),
      headlineMedium: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkGray,
      ),
      titleLarge: GoogleFonts.merriweather(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkGray,
      ),
      titleMedium: GoogleFonts.merriweather(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkGray,
      ),
      bodyLarge: GoogleFonts.merriweather(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: darkGray,
      ),
      bodyMedium: GoogleFonts.merriweather(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: darkGray,
      ),
      labelLarge: GoogleFonts.merriweather(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: darkGray,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: lightGreen,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        side: const BorderSide(color: primaryGreen),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: _createMaterialColor(primaryGreen),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6EE7B7), // Lighter green for dark mode
      secondary: secondaryGreen,
      surface: Color(0xFF262626),
      background: Color(0xFF171717),
      onBackground: Color(0xFFF5F5F5),
      onSurface: Color(0xFFF5F5F5),
    ),
    textTheme: GoogleFonts.merriweatherTextTheme(
      const TextTheme().apply(
        bodyColor: Color(0xFFF5F5F5),
        displayColor: Color(0xFF6EE7B7),
      ),
    ).copyWith(
      displayLarge: GoogleFonts.merriweather(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Color(0xFF6EE7B7),
      ),
      displayMedium: GoogleFonts.merriweather(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: Color(0xFF6EE7B7),
      ),
      displaySmall: GoogleFonts.merriweather(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6EE7B7),
      ),
      headlineLarge: GoogleFonts.merriweather(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF5F5F5),
      ),
      headlineMedium: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF5F5F5),
      ),
      titleLarge: GoogleFonts.merriweather(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF5F5F5),
      ),
      titleMedium: GoogleFonts.merriweather(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFF5F5F5),
      ),
      bodyLarge: GoogleFonts.merriweather(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFFF5F5F5),
      ),
      bodyMedium: GoogleFonts.merriweather(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Color(0xFFF5F5F5),
      ),
      labelLarge: GoogleFonts.merriweather(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF171717),
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFF171717),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF171717),
      foregroundColor: Color(0xFFF5F5F5),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF262626),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6EE7B7),
        foregroundColor: const Color(0xFF171717),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  static MaterialColor _createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}