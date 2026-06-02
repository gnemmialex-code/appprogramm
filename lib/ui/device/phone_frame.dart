import 'package:flutter/material.dart';

/// Wraps the whole app in a realistic **iPhone 16** device mock-up when shown
/// on a large surface (web / desktop), so localhost previews look like a real
/// phone — titanium frame, rounded screen, Dynamic Island and home indicator.
///
/// On an actual phone-sized window the frame is skipped and the app fills the
/// screen. The inner [MediaQuery] is overridden so routed pages believe they
/// run on a 393×852 iPhone 16 viewport with correct safe-area insets.
class PhoneFrame extends StatelessWidget {
  final Widget child;
  const PhoneFrame({super.key, required this.child});

  // iPhone 16 logical resolution (points).
  static const double screenW = 393;
  static const double screenH = 852;

  static const double bezel = 14; // titanium border thickness
  static const double screenRadius = 52; // inner display corner radius
  static const double deviceRadius = screenRadius + bezel;

  // Safe-area insets (Dynamic Island top, home indicator bottom).
  static const double safeTop = 59;
  static const double safeBottom = 34;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    // Real phone-sized window → render the app full screen, no frame.
    final showFrame = media.size.width > 520 && media.size.height > 640;
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
            // The actual app, fooled into thinking it's on an iPhone 16.
            Positioned.fill(
              child: MediaQuery(
                data: media.copyWith(
                  size: const Size(screenW, screenH),
                  padding: const EdgeInsets.only(
                      top: safeTop, bottom: safeBottom),
                  viewPadding: const EdgeInsets.only(
                      top: safeTop, bottom: safeBottom),
                  viewInsets: EdgeInsets.zero,
                  devicePixelRatio: 3,
                ),
                child: child,
              ),
            ),
            // Dynamic Island.
            const Positioned(
              top: 11,
              left: 0,
              right: 0,
              child: Center(child: _DynamicIsland()),
            ),
            // Home indicator.
            Positioned(
              bottom: 9,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 140,
                  height: 5,
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
        // Titanium body.
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
        // Side buttons (cosmetic).
        const _SideButton(top: 150, left: true, height: 26), // mute
        const _SideButton(top: 200, left: true, height: 50), // volume up
        const _SideButton(top: 262, left: true, height: 50), // volume down
        const _SideButton(top: 220, left: false, height: 78), // power
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

class _DynamicIsland extends StatelessWidget {
  const _DynamicIsland();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126,
      height: 37,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Front camera lens.
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: const Color(0xFF1C2330),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2B3445)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final double top;
  final double height;
  final bool left;
  const _SideButton({
    required this.top,
    required this.height,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
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
