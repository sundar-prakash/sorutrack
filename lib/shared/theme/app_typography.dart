import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

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
    final Color highEmphasis = brightness == Brightness.light
        ? AppColors.textHighEmphasisLight
        : AppColors.textHighEmphasisDark;
    final Color mediumEmphasis = brightness == Brightness.light
        ? AppColors.textMediumEmphasisLight
        : AppColors.textMediumEmphasisDark;
    final Color disabled = brightness == Brightness.light
        ? AppColors.textDisabledLight
        : AppColors.textDisabledDark;

    return TextTheme(
      displayLarge: display.copyWith(color: highEmphasis),
      displayMedium: display.copyWith(fontSize: 28, color: highEmphasis),
      displaySmall: display.copyWith(fontSize: 24, color: highEmphasis),
      
      headlineLarge: headline.copyWith(color: highEmphasis),
      headlineMedium: headline.copyWith(fontSize: 20, color: highEmphasis),
      headlineSmall: headline.copyWith(fontSize: 18, color: highEmphasis),
      
      titleLarge: title.copyWith(color: highEmphasis),
      titleMedium: title.copyWith(fontSize: 16, color: highEmphasis),
      titleSmall: title.copyWith(fontSize: 14, color: highEmphasis),
      
      bodyLarge: body.copyWith(fontSize: 16, color: highEmphasis),
      bodyMedium: body.copyWith(color: highEmphasis),
      bodySmall: body.copyWith(fontSize: 12, color: mediumEmphasis),
      
      labelLarge: body.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: highEmphasis),
      labelMedium: caption.copyWith(color: mediumEmphasis),
      labelSmall: caption.copyWith(fontSize: 10, color: disabled),
    );
  }
}
