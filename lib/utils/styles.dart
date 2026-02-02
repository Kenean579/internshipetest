import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color secondary = Color(0xFFEC4899); // Pink 500
  static const Color background = Color(0xFFF3F4F6); // Gray 100
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937); // Gray 800
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color error = Color(0xFFEF4444); // Red 500
}

class AppTextStyles {
  static TextStyle get header => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get subHeader => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get body =>
      GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary);

  static TextStyle get bodySecondary =>
      GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary);

  static TextStyle get button => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
