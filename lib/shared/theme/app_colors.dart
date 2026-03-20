import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF74C69D);
  static const Color accent = Color(0xFFF4A261);

  // Semantic Colors
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  // Backgrounds & Surfaces (Light)
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Backgrounds & Surfaces (Dark)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors (Light Mode)
  static const Color textHighEmphasisLight = Color(0xDE000000); // 87% Black
  static const Color textMediumEmphasisLight = Color(0x99000000); // 60% Black
  static const Color textDisabledLight = Color(0x61000000); // 38% Black

  // Text Colors (Dark Mode)
  static const Color textHighEmphasisDark = Color(0xFFFFFFFF); // 100% White
  static const Color textMediumEmphasisDark = Color(0xB3FFFFFF); // 70% White
  static const Color textDisabledDark = Color(0x80FFFFFF); // 50% White
  
  // Dividers & Borders
  static const Color dividerLight = Color(0x1F000000); // 12% Black
  static const Color dividerDark = Color(0x1FFFFFFF); // 12% White
}
