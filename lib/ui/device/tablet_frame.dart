import 'package:flutter/material.dart';

/// Wraps the whole app in a realistic **13-inch iPad Pro** device mock-up when
/// shown on a large surface (web / desktop), so localhost previews look like a
/// real tablet — aluminium frame, uniform rounded bezel, front camera and home
/// indicator.
///
/// On an actual tablet-sized window the frame is skipped and the app fills the
/// screen. The inner [MediaQuery] is overridden so routed pages believe they
/// run on a 1024×1366 iPad viewport (2048×2732 px @ devicePixelRatio 2) with
/// correct safe-area insets.
class TabletFrame extends StatelessWidget {
  final Widget child;
  const TabletFrame({super.key, required this.child});

  // 13" iPad Pro logical resolution (points), portrait.
  // Physical pixels = points × devicePixelRatio(2) = 2048 × 2732.
  static const double screenW = 1024;
  static const double screenH = 1366;

  static const double bezel = 22; // uniform aluminium border thickness
  static const double screenRadius = 24; // inner display corner radius
  static const double deviceRadius = screenRadius + bezel;

  // Safe-area insets (status bar top, home indicator bottom).
  static const double safeTop = 24;
  static const double safeBottom = 20;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    // Real tablet-sized window → render the app full screen, no frame.
    // The frame is only meant for large web/desktop previews; it is scaled by
    // the FittedBox below so it still fits on shorter windows.
    final showFrame = media.size.width > 500;
    if (!showFrame) return child;

    const deviceW = screenW + bezel * 2;
    const deviceH = screenH + bezel * 2;

    final screen = ClipRRect(
      borderRadius: BorderRadius.circular(screenRadius),
      child: SizedBox(
        width: screenW,
        height: screenH,
        child: Stack(
          children: [
            // The actual app, fooled into thinking it's on a 13" iPad.
            Positioned.fill(
              child: MediaQuery(
                data: media.copyWith(
                  size: const Size(screenW, screenH),
                  padding: const EdgeInsets.only(
                    top: safeTop,
                    bottom: safeBottom,
                  ),
                  viewPadding: const EdgeInsets.only(
                    top: safeTop,
                    bottom: safeBottom,
                  ),
                  viewInsets: EdgeInsets.zero,
                  devicePixelRatio: 2,
                ),
                child: child,
              ),
            ),
            // Front camera lens (centred in the top bezel area).
            const Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(child: _FrontCamera()),
            ),
            // Home indicator.
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 280,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final device = Stack(
      clipBehavior: Clip.none,
      children: [
        // Aluminium body.
        Container(
          width: deviceW,
          height: deviceH,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3A3A40), Color(0xFF0C0C0F)],
            ),
            borderRadius: BorderRadius.circular(deviceRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 60,
                spreadRadius: 4,
                offset: const Offset(0, 30),
              ),
            ],
          ),
          padding: const EdgeInsets.all(bezel),
          child: screen,
        ),
        // Side buttons (cosmetic): power + volume on the top-right edge region.
        const _SideButton(top: -3, left: false, height: 70, horizontal: true),
        const _SideButton(top: 150, left: false, height: 90),
      ],
    );

    return ColoredBox(
      color: const Color(0xFFE9EBF2),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FittedBox(fit: BoxFit.contain, child: device),
        ),
      ),
    );
  }
}

class _FrontCamera extends StatelessWidget {
  const _FrontCamera();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: const Color(0xFF1C2330),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2B3445)),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final double top;
  final double height;
  final bool left;

  /// When true the button lies flat on the top edge (e.g. the power button),
  /// otherwise it runs vertically along the left/right side.
  final bool horizontal;

  const _SideButton({
    required this.top,
    required this.height,
    required this.left,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (horizontal) {
      return Positioned(
        top: -3,
        right: 80,
        child: Container(
          width: height,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A30),
            borderRadius: BorderRadius.vertical(top: const Radius.circular(3)),
          ),
        ),
      );
    }
    return Positioned(
      top: top,
      left: left ? -3 : null,
      right: left ? null : -3,
      child: Container(
        width: 4,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A30),
          borderRadius: BorderRadius.horizontal(
            left: left ? Radius.zero : const Radius.circular(3),
            right: left ? const Radius.circular(3) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
