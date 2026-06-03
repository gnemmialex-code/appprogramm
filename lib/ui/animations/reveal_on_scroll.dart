import 'package:flutter/material.dart';

/// Reveals [child] with a fade + upward slide **the moment it scrolls into the
/// viewport** — and only once. Unlike a fixed entrance animation, items below
/// the fold stay hidden until the user actually reaches them, giving a lively
/// "content comes alive as you scroll" feel.
///
/// Dependency-free: it listens to the enclosing [Scrollable]'s position and
/// measures its own box *relative to the viewport*, so it behaves correctly
/// even inside the scaled iPhone preview frame. Honours the OS "reduce motion"
/// accessibility setting by showing instantly.
class RevealOnScroll extends StatefulWidget {
  final Widget child;
  final double offset;
  final Duration duration;
  final Curve curve;

  /// Fraction of the viewport height the top edge must cross before revealing.
  /// `0.0` fires as soon as the edge peeks in; `0.1` waits until it is 10% in.
  final double threshold;

  const RevealOnScroll({
    super.key,
    required this.child,
    this.offset = 28,
    this.duration = const Duration(milliseconds: 560),
    this.curve = Curves.easeOutCubic,
    this.threshold = 0.05,
  });

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  ScrollPosition? _position;
  bool _revealed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newPos = Scrollable.maybeOf(context)?.position;
    if (newPos != _position) {
      _position?.removeListener(_maybeReveal);
      _position = newPos;
      _position?.addListener(_maybeReveal);
    }
    // Reveal items already on screen at first layout.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeReveal());
  }

  void _maybeReveal() {
    if (_revealed || !mounted) return;

    // Respect the OS "reduce motion" setting → show instantly.
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _reveal(animate: false);
      return;
    }

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) {
      _reveal(); // Not in a scroll view — just animate in.
      return;
    }

    final viewport = scrollable.context.findRenderObject() as RenderBox?;
    final self = context.findRenderObject() as RenderBox?;
    if (viewport == null || self == null || !self.attached) return;

    final topInViewport = self
        .localToGlobal(Offset.zero, ancestor: viewport)
        .dy;
    final triggerLine = viewport.size.height * (1 - widget.threshold);
    if (topInViewport < triggerLine) _reveal();
  }

  void _reveal({bool animate = true}) {
    if (_revealed) return;
    _revealed = true;
    _position?.removeListener(_maybeReveal);
    if (animate) {
      _c.forward();
    } else {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_maybeReveal);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: widget.curve);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - curved.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
