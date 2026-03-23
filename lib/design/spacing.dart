import 'package:flutter/material.dart';

/// BillSplit AI — Spacing & Layout System
/// 4px base grid — consistent, predictable, scalable

abstract class AppSpacing {
  // ─── Base Units (4px grid) ────────────────────────────────────────────────
  static const double xs = 4.0;    // 4px
  static const double sm = 8.0;    // 8px
  static const double md = 12.0;   // 12px
  static const double base = 16.0; // 16px
  static const double lg = 20.0;   // 20px
  static const double xl = 24.0;   // 24px
  static const double x2l = 32.0;  // 32px
  static const double x3l = 40.0;  // 40px
  static const double x4l = 48.0;  // 48px
  static const double x5l = 64.0;  // 64px
  static const double x6l = 80.0;  // 80px

  // ─── Semantic Spacing ────────────────────────────────────────────────────
  static const double screenPadding = base;          // 16px horizontal screen padding
  static const double screenPaddingLarge = xl;       // 24px for larger screens
  static const double cardPadding = base;            // 16px inside cards
  static const double cardPaddingLarge = xl;         // 24px inside large cards
  static const double itemSpacing = sm;              // 8px between list items
  static const double sectionSpacing = x2l;          // 32px between sections
  static const double sectionSpacingSmall = xl;      // 24px between close sections
  static const double inputSpacing = md;             // 12px between form fields
  static const double buttonHeight = 52.0;           // Standard button height
  static const double buttonHeightSmall = 40.0;      // Small button height
  static const double iconSize = 24.0;               // Standard icon size
  static const double iconSizeSmall = 20.0;          // Small icon
  static const double iconSizeLarge = 32.0;          // Large icon
  static const double avatarSize = 40.0;             // Member avatar
  static const double avatarSizeLarge = 56.0;        // Large avatar
  static const double bottomNavHeight = 72.0;        // Bottom nav bar
  static const double appBarHeight = 60.0;           // App bar

  // ─── Border Radius ───────────────────────────────────────────────────────
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusX2l = 24.0;
  static const double radiusFull = 100.0;

  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusX2l = BorderRadius.all(Radius.circular(radiusX2l));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // ─── Elevation / Shadow ──────────────────────────────────────────────────
  static List<BoxShadow> get shadowXs => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.06),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.10),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowPrimary => [
        BoxShadow(
          color: const Color(0xFF4F46E5).withOpacity(0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  // ─── Edge Insets helpers ─────────────────────────────────────────────────
  static const EdgeInsets paddingScreen =
      EdgeInsets.symmetric(horizontal: screenPadding);

  static const EdgeInsets paddingAll4 = EdgeInsets.all(xs);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(sm);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(md);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(base);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(lg);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(xl);

  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets paddingV8 = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: base);

  // ─── SizedBox helpers ────────────────────────────────────────────────────
  static const Widget hXs = SizedBox(height: xs);
  static const Widget hSm = SizedBox(height: sm);
  static const Widget hMd = SizedBox(height: md);
  static const Widget hBase = SizedBox(height: base);
  static const Widget hLg = SizedBox(height: lg);
  static const Widget hXl = SizedBox(height: xl);
  static const Widget hX2l = SizedBox(height: x2l);
  static const Widget hX3l = SizedBox(height: x3l);

  static const Widget wXs = SizedBox(width: xs);
  static const Widget wSm = SizedBox(width: sm);
  static const Widget wMd = SizedBox(width: md);
  static const Widget wBase = SizedBox(width: base);
  static const Widget wLg = SizedBox(width: lg);
  static const Widget wXl = SizedBox(width: xl);
}
