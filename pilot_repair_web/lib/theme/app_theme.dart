import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern Color Scheme
  static const primaryColor = Color(0xFF10B981); // Emerald green
  static const secondaryColor = Color(0xFF059669); // Darker emerald
  static const accentColor = Color(0xFF34D399); // Light emerald
  static const warningColor = Color(0xFFF59E0B); // Amber
  static const dangerColor = Color(0xFFEF4444); // Red
  static const backgroundColor = Color(0xFFF8FAFC);
  static const surfaceColor = Color(0xFFFFFFFF);
  static const textColor = Color(0xFF1E293B);
  static const mutedTextColor = Color(0xFF64748B);

  // Dark Mode Colors
  static const darkPrimaryColor = Color(0xFF34D399); // Light emerald for better visibility
  static const darkAccentColor = Color(0xFF10B981); // Emerald
  static const darkBackgroundColor = Color(0xFF0F172A);
  static const darkSurfaceColor = Color(0xFF1E293B);
  static const darkTextColor = Color(0xFFF8FAFC);
  static const darkMutedTextColor = Color(0xFF94A3B8);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: surfaceColor,
      onBackground: textColor,
      onSurface: textColor,
      error: dangerColor,
      onError: Colors.white,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: surfaceColor,
      clipBehavior: Clip.antiAliasWithSaveLayer,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.poppins(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.poppins(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: textColor,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: mutedTextColor,
        fontSize: 14,
        height: 1.6,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: mutedTextColor.withOpacity(0.7),
        fontSize: 14,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith<double>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return 2;
            }
            return 0;
          },
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    iconTheme: const IconThemeData(
      size: 20,
      color: textColor,
    ),
    dividerTheme: DividerThemeData(
      color: textColor.withOpacity(0.1),
      thickness: 1,
      space: 1,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: secondaryColor,
      background: darkBackgroundColor,
      surface: darkSurfaceColor,
      onBackground: darkTextColor,
      onSurface: darkTextColor,
      error: dangerColor,
      onError: Colors.white,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: darkSurfaceColor,
      clipBehavior: Clip.antiAliasWithSaveLayer,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurfaceColor,
      elevation: 0,
      iconTheme: IconThemeData(color: darkTextColor),
      titleTextStyle: TextStyle(
        color: darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(
        color: darkTextColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: darkTextColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.poppins(
        color: darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.poppins(
        color: darkTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: darkTextColor,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: darkMutedTextColor,
        fontSize: 14,
        height: 1.6,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: darkMutedTextColor.withOpacity(0.7),
        fontSize: 14,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith<double>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return 2;
            }
            return 0;
          },
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    iconTheme: const IconThemeData(
      size: 20,
      color: darkTextColor,
    ),
    dividerTheme: DividerThemeData(
      color: darkTextColor.withOpacity(0.1),
      thickness: 1,
      space: 1,
    ),
  );
} 