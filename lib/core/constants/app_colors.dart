import 'package:flutter/material.dart';

/// Cowrywise-inspired palette for Koins MFB.
class AppColors {
  const AppColors._();

  // Brand
  static const Color navy = Color(0xFF14142B);
  static const Color navyDeep = Color(0xFF0B0B1A);
  static const Color navySoft = Color(0xFF262645);
  static const Color primary = Color(0xFF3A3AFF);
  static const Color primaryDark = Color(0xFF2626CC);
  static const Color gold = Color(0xFFFFC46B);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEFF1F7);
  static const Color border = Color(0xFFE3E6F0);
  static const Color textPrimary = Color(0xFF14142B);
  static const Color textSecondary = Color(0xFF6E7191);
  static const Color textTertiary = Color(0xFFA0A3BD);

  // Feedback
  static const Color success = Color(0xFF1FA97C);
  static const Color error = Color(0xFFE2445C);
  static const Color warning = Color(0xFFF5A623);

  // Accent ramp, one colour per savings product card.
  static const List<Color> accents = <Color>[
    Color(0xFF3A3AFF),
    Color(0xFF1FA97C),
    Color(0xFF7B61FF),
    Color(0xFFF5A623),
  ];

  /// Returns a stable accent colour for [index], wrapping around the ramp.
  static Color accentAt(int index) => accents[index % accents.length];

  /// Gradient used on the dashboard balance card.
  static const LinearGradient balanceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[navy, Color(0xFF2B2B5A)],
  );
}
