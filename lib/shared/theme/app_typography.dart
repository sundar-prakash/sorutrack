import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Display
  static TextStyle get display => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  // Headline
  static TextStyle get headline => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w600, // SemiBold
      );

  // Title
  static TextStyle get title => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600, // SemiBold
      );

  // Body
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400, // Regular
      );

  // Caption
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400, // Regular
      );

  // Special Large Display (Calories number)
  static TextStyle get caloriesNumber => GoogleFonts.nunito(
        fontSize: 48,
        fontWeight: FontWeight.bold,
      );
      
  /// Generates the complete TextTheme for Material 3
  static TextTheme getTextTheme({required Brightness brightness}) {
    final Color textColor =
        brightness == Brightness.light ? Colors.black87 : Colors.white;

    return TextTheme(
      displayLarge: display.copyWith(color: textColor),
      displayMedium: display.copyWith(fontSize: 28, color: textColor),
      displaySmall: display.copyWith(fontSize: 24, color: textColor),
      
      headlineLarge: headline.copyWith(color: textColor),
      headlineMedium: headline.copyWith(fontSize: 20, color: textColor),
      headlineSmall: headline.copyWith(fontSize: 18, color: textColor),
      
      titleLarge: title.copyWith(color: textColor),
      titleMedium: title.copyWith(fontSize: 16, color: textColor),
      titleSmall: title.copyWith(fontSize: 14, color: textColor),
      
      bodyLarge: body.copyWith(fontSize: 16, color: textColor),
      bodyMedium: body.copyWith(color: textColor),
      bodySmall: body.copyWith(fontSize: 12, color: textColor),
      
      labelLarge: body.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
      labelMedium: caption.copyWith(color: textColor),
      labelSmall: caption.copyWith(fontSize: 10, color: textColor),
    );
  }
}
