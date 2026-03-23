import 'package:flutter/material.dart';

/// BillSplit AI — Color Design System
/// Palette: Deep Indigo + Electric Violet + Soft Mint accent
/// Inspired by modern fintech apps (Revolut, Wise, Splitwise 2.0)

abstract class AppColors {
  // ─── Primary Brand ───────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4F46E5);       // Indigo-600
  static const Color primaryLight = Color(0xFF818CF8);  // Indigo-400
  static const Color primaryDark = Color(0xFF3730A3);   // Indigo-800
  static const Color primarySurface = Color(0xFFEEF2FF); // Indigo-50

  // ─── Accent ──────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF10B981);        // Emerald-500 (mint)
  static const Color accentLight = Color(0xFF6EE7B7);   // Emerald-300
  static const Color accentDark = Color(0xFF047857);    // Emerald-700
  static const Color accentSurface = Color(0xFFECFDF5); // Emerald-50

  // ─── Semantic ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);       // Green-500
  static const Color successSurface = Color(0xFFF0FDF4);
  static const Color error = Color(0xFFEF4444);         // Red-500
  static const Color errorSurface = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B);       // Amber-500
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF3B82F6);          // Blue-500
  static const Color infoSurface = Color(0xFFEFF6FF);

  // ─── Neutrals ────────────────────────────────────────────────────────────
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ─── Background & Surface ────────────────────────────────────────────────
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // ─── Dark Mode ───────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F172A);    // Slate-900
  static const Color surfaceDark = Color(0xFF1E293B);       // Slate-800
  static const Color surfaceVariantDark = Color(0xFF334155); // Slate-700
  static const Color surfaceElevatedDark = Color(0xFF1E293B);

  // ─── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // ─── Borders ─────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);
  static const Color borderFocus = Color(0xFF4F46E5);

  // ─── Financial specific ──────────────────────────────────────────────────
  static const Color positive = Color(0xFF22C55E);  // Money received / owed to you
  static const Color negative = Color(0xFFEF4444);  // Money you owe
  static const Color neutral = Color(0xFF6B7280);   // Settled / zero balance

  // ─── Gradients ───────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Avatar Colors (for group members) ───────────────────────────────────
  static const List<Color> avatarColors = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];

  static Color avatarColor(int index) =>
      avatarColors[index % avatarColors.length];
}
