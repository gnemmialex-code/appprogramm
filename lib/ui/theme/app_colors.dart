import 'package:flutter/material.dart';

/// Centralised pastel / premium colour palette (Apple-like, minimalist).
class AppColors {
  AppColors._();

  // Base
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1C1C28);
  static const Color inkSoft = Color(0xFF6E6E80);
  static const Color line = Color(0xFFE9EAF0);

  // Accents (pastel)
  static const Color lavender = Color(0xFFB8A6FF);
  static const Color sky = Color(0xFF8FD0FF);
  static const Color mint = Color(0xFF9FE6C4);
  static const Color peach = Color(0xFFFFC2A6);
  static const Color rose = Color(0xFFFFA6C4);
  static const Color sun = Color(0xFFFFD98F);

  // Brand gradient
  static const Color brandStart = Color(0xFF7C6CFF);
  static const Color brandEnd = Color(0xFF9F7CFF);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandStart, brandEnd],
  );

  // Semantic
  static const Color success = Color(0xFF34C759);
  static const Color danger = Color(0xFFFF3B30);

  /// Soft shadow used on cards.
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF1C1C28).withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
}
