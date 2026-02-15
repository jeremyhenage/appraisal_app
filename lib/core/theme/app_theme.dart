import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defines the global theme for the Appraisal App.
///
/// Implements the "Tactical Dark" aesthetic using [FlexColorScheme].
class AppTheme {
  // Private constructor to prevent instantiation.
  AppTheme._();

  /// The main background color for the app (Deep Matte Grey).
  static const Color _surfaceColor = Color(0xFF121212);

  /// The primary accent color (Neon Cyan).
  static const Color _primaryColor = Color(0xFF00E5FF);

  /// The secondary accent color, often used for variations.
  static const Color _secondaryColor = Color(0xFF00B8D4);

  /// Color indicating success or safe status (Matrix Green).
  static const Color _successColor = Color(0xFF00FF41);

  /// Color indicating error or danger status (Bitcrush Red).
  static const Color _errorColor = Color(0xFFFF0055);

  /// Returns the definition for the dark theme.
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.materialBaseline,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        textButtonRadius: 8.0,
        elevatedButtonRadius: 8.0,
        outlinedButtonRadius: 8.0,
        inputDecoratorRadius: 8.0,
        inputDecoratorUnfocusedBorderIsColored: false,
        fabUseShape: true,
        fabRadius: 32.0,
        chipRadius: 8.0,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      // Manual overrides for specific "Tactical" look
      colors: const FlexSchemeColor(
        primary: _primaryColor,
        primaryContainer: _secondaryColor,
        secondary: _secondaryColor,
        secondaryContainer: _primaryColor,
        tertiary: _successColor,
        tertiaryContainer: _successColor,
        appBarColor: _surfaceColor,
        error: _errorColor,
      ),
    ).copyWith(
      scaffoldBackgroundColor: _surfaceColor,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.jetBrainsMono(
          color: _primaryColor,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.jetBrainsMono(
          color: _primaryColor,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.jetBrainsMono(
          color: _primaryColor,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.jetBrainsMono(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.jetBrainsMono(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.jetBrainsMono(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: Colors.white70,
        ),
        bodyMedium: GoogleFonts.inter(
          color: Colors.white60,
        ),
      ),
    );
  }
}
