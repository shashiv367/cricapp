import 'package:flutter/material.dart';

/// Color palette inspired by the dark blue Cricbuzz UI design.
class AppColors {
  static const Color backgroundDark = Color(0xFF020617); // deep navy
  static const Color backgroundCard = Color(0xFF0B1220); // dark card
  static const Color backgroundCardAlt = Color(0xFF111827); // secondary card

  static const Color primaryBlue = Color(0xFF38BDF8); // cyan/blue accents
  static const Color accentRed = Color(0xFFFB7185); // live badge
  static const Color accentGreen = Color(0xFF4ADE80);

  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color divider = Color(0xFF1F2933);

  // Backwards-compatible aliases for older light-theme names
  static const Color primaryPurple = primaryBlue;
  static const Color darkPurple = backgroundCardAlt;
  static const Color lightPurple = primaryBlue;
  static const Color accentYellow = primaryBlue;
  static const Color successGreen = accentGreen;
  static const Color errorRed = accentRed;
  static const Color backgroundWhite = backgroundDark;
  static const Color textDark = textPrimary;
  static const Color textLight = textSecondary;
  static const Color liveRed = accentRed;
}

