import 'package:flutter/material.dart';

/// Centralised pastel / premium colour palette (Apple-like, minimalist).
///
/// The five **semantic** colours (background, surface, ink, inkSoft, line) and
/// [softShadow] adapt to [brightness], which the app root sets from the user's
/// persisted theme choice. The pastel accents and brand gradient are identical
/// in both light and dark themes.
class AppColors {
  AppColors._();

  /// Active theme brightness. Set once by the app root (from the persisted
  /// preference) before each build, so every semantic colour read below
  /// reflects the current light/dark mode.
  static Brightness brightness = Brightness.light;
  static bool get isDark => brightness == Brightness.dark;

  // Base (theme-aware)
  static Color get background =>
      isDark ? const Color(0xFF0E0E13) : const Color(0xFFF6F7FB);
  static Color get surface =>
      isDark ? const Color(0xFF1C1C26) : const Color(0xFFFFFFFF);
  static Color get ink =>
      isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1C1C28);
  static Color get inkSoft =>
      isDark ? const Color(0xFF9B9BAC) : const Color(0xFF6E6E80);
  static Color get line =>
      isDark ? const Color(0xFF2C2C3A) : const Color(0xFFE9EAF0);

  // Accents (pastel) — identical in both themes
  static const Color lavender = Color(0xFFB8A6FF);
  static const Color sky = Color(0xFF8FD0FF);
  static const Color mint = Color(0xFF9FE6C4);
  static const Color peach = Color(0xFFFFC2A6);
  static const Color rose = Color(0xFFFFA6C4);
  static const Color sun = Color(0xFFFFD98F);

  // Extra accents — used by the broader catalogue of domains
  static const Color indigo = Color(0xFF8C9EFF);
  static const Color coral = Color(0xFFFF8E72);
  static const Color aqua = Color(0xFF77D7CE);
  static const Color lime = Color(0xFFB6E08A);
  static const Color gold = Color(0xFFE9C46A);
  static const Color blush = Color(0xFFE3A8F0);

  // Brand gradient
  static const Color brandStart = Color(0xFF7C6CFF);
  static const Color brandEnd = Color(0xFF9F7CFF);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandStart, brandEnd],
  );

  // Expert mode accents
  static const Color deepPurple = Color(0xFF6B4FBF);
  static const Color teal = Color(0xFF2FB8AC);

  // Semantic
  static const Color success = Color(0xFF34C759);
  static const Color danger = Color(0xFFFF3B30);

  /// Soft shadow used on cards — a touch deeper on dark surfaces.
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.06),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
}
