import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design tokens for Ridr - Bike Rental Manager.
/// Clean, minimalist design with bold typography.
class AppColors {
  static const Color primaryRed = Color(0xFFEF4A3F);
  static const Color primaryRedDark = Color(0xFFD8362B);

  static const Color surface = Color(0xFFF6F7F9);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardMuted = Color(0xFFE7EAEE);

  static const Color textPrimary = Color(0xFF1B1D21);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color success = Color(0xFF2FAE60);
  static const Color danger = Color(0xFFE04B3F);
  static const Color warning = Color(0xFFF2A93B);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryRed,
        primary: AppColors.primaryRed,
        surface: AppColors.surface,
        brightness: Brightness.light,
      ),

      scaffoldBackgroundColor: AppColors.surface,

      // Default font
      fontFamily: GoogleFonts.manrope().fontFamily,
    );

    return base.copyWith(

      // --------------------------------------------------
      // APP BAR
      // --------------------------------------------------

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,

        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),

      // --------------------------------------------------
      // TEXT THEME
      // --------------------------------------------------

      textTheme: GoogleFonts.manropeTextTheme(
        base.textTheme,
      ).copyWith(

        // Very large headings
        displayLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),

        displayMedium: GoogleFonts.manrope(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),

        displaySmall: GoogleFonts.manrope(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),

        // Main headings
        headlineLarge: GoogleFonts.manrope(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),

        headlineMedium: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),

        headlineSmall: GoogleFonts.manrope(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),

        // Titles
        titleLarge: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),

        titleMedium: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),

        titleSmall: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),

        // Body
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),

        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),

        bodySmall: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),

        // Labels / buttons
        labelLarge: GoogleFonts.manrope(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),

        labelMedium: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),

        labelSmall: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),

      // --------------------------------------------------
      // ELEVATED BUTTON
      // --------------------------------------------------

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,

          elevation: 0,

          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      // --------------------------------------------------
      // OUTLINED BUTTON
      // --------------------------------------------------

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,

          side: const BorderSide(
            color: AppColors.cardMuted,
            width: 1.4,
          ),

          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      // --------------------------------------------------
      // INPUT FIELDS
      // --------------------------------------------------

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.cardMuted,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryRed,
            width: 1.6,
          ),
        ),

        labelStyle: GoogleFonts.manrope(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),

        hintStyle: GoogleFonts.manrope(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),

      // --------------------------------------------------
      // CARD
      // --------------------------------------------------

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        margin: EdgeInsets.zero,
      ),

      // --------------------------------------------------
      // DIVIDERS
      // --------------------------------------------------

      dividerTheme: const DividerThemeData(
        color: AppColors.cardMuted,
        thickness: 1,
      ),

      // --------------------------------------------------
      // ICONS
      // --------------------------------------------------

      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
      ),
    );
  }
}