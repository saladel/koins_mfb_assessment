import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Spacing scale. Use these instead of magic numbers so padding stays
/// consistent across every screen.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal page gutter used by every screen.
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: lg);
}

/// Corner radii.
class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(xl);
  static BorderRadius get field => BorderRadius.circular(md);
  static BorderRadius get chip => BorderRadius.circular(pill);
}

/// Elevation is faked with soft shadows so cards read the same on both
/// platforms.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F14142B),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A14142B),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];
}

/// Animation durations.
class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

/// Shared decoration for white content cards.
class AppDecorations {
  const AppDecorations._();

  static BoxDecoration get card => BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      );

  static BoxDecoration get outlinedCard => BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      );
}
