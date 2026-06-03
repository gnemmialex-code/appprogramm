import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// App-wide scroll behaviour tuned for a smooth, iOS-like feel.
///
/// * **Bouncing physics** everywhere — momentum + rubber-band overscroll
///   instead of the default Android clamp, so every list/grid glides.
/// * **Drag with mouse & trackpad** so the web preview scrolls by dragging,
///   not just the wheel.
/// * **No glow overscroll indicator** — the bounce already gives feedback and
///   the glow clashes with the pastel surfaces.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child; // Bounce provides the overscroll feedback; skip the glow.
}
