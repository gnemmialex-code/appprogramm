import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A [HeroFlightShuttleBuilder] for the `domain-<id>` Hero shared between the
/// home grid (a rounded-square tinted icon) and the domain detail header (a
/// white icon on a translucent circle).
///
/// During the flight it interpolates background colour, icon colour and corner
/// radius so the square tile morphs smoothly into the circular avatar — much
/// cleaner than the default cross-fade, and free of any jitter from the home
/// screen's idle bob.
HeroFlightShuttleBuilder domainHeroShuttle(IconData icon, Color color) {
  return (flightContext, animation, direction, fromContext, toContext) {
    final tinted = color.withValues(alpha: 0.22);
    final glass = Colors.white.withValues(alpha: 0.20);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final bg = Color.lerp(tinted, glass, t)!;
        final iconColor = Color.lerp(AppColors.ink, Colors.white, t)!;
        // 1/3 (rounded square) → 1/2 (circle) of the shortest side.
        final radiusFactor = 0.333 + 0.167 * t;

        return LayoutBuilder(
          builder: (context, constraints) {
            final side = constraints.biggest.shortestSide;
            return Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(side * radiusFactor),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: side * 0.5),
            );
          },
        );
      },
    );
  };
}
