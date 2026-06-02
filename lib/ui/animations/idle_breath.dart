import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Wraps [child] and, while [active] is true, gently enlarges it and runs a
/// soft "breathing" pulse to draw attention. When [active] becomes false it
/// smoothly returns to its normal size. Used to wake up the home buttons after
/// a few seconds of inactivity so nothing stays static.
class IdleBreath extends StatefulWidget {
  final bool active;
  final Widget child;
  final double grow; // extra scale applied when active
  final double breath; // amplitude of the continuous pulse

  const IdleBreath({
    super.key,
    required this.active,
    required this.child,
    this.grow = 0.05,
    this.breath = 0.03,
  });

  @override
  State<IdleBreath> createState() => _IdleBreathState();
}

class _IdleBreathState extends State<IdleBreath>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant IdleBreath old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _c.repeat(reverse: true);
    } else if (!widget.active && old.active) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      scale: widget.active ? 1 + widget.grow : 1.0,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          // Smooth 0→1→0 bump via sine.
          final pulse = widget.active
              ? 1 + widget.breath * math.sin(_c.value * math.pi)
              : 1.0;
          return Transform.scale(scale: pulse, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// A subtle, never-ending vertical bob — keeps small accents (icons) alive.
class AmbientBob extends StatefulWidget {
  final Widget child;
  final double distance;
  final Duration period;

  const AmbientBob({
    super.key,
    required this.child,
    this.distance = 4,
    this.period = const Duration(milliseconds: 2200),
  });

  @override
  State<AmbientBob> createState() => _AmbientBobState();
}

class _AmbientBobState extends State<AmbientBob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period)
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = math.sin(_c.value * math.pi);
        return Transform.translate(
          offset: Offset(0, -widget.distance * t),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
