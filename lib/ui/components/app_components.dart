import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A soft, rounded surface card with a gentle shadow — the visual building
/// block reused across the app.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? (color ?? AppColors.surface) : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.softShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Linear progress bar with rounded ends and a brand gradient fill.
class GradientProgressBar extends StatelessWidget {
  final double value; // 0..1
  final double height;

  const GradientProgressBar({super.key, required this.value, this.height = 12});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: AppColors.line),
          LayoutBuilder(
            builder: (context, c) => AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              height: height,
              width: c.maxWidth * value.clamp(0, 1),
              decoration: const BoxDecoration(gradient: AppColors.brandGradient),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small pill used for badges and tags.
class BadgeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const BadgeChip({
    super.key,
    required this.label,
    this.icon = Icons.emoji_events_rounded,
    this.color = AppColors.sun,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.ink),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// A full-width rounded primary button with a gradient background.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandStart.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small circular icon avatar with a tinted background.
class TintedIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const TintedIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(icon, color: AppColors.ink, size: size * 0.5),
    );
  }
}
