import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_providers.dart';
import '../../ui/theme/app_colors.dart';
import '../domain_selection/domains_data.dart';

/// Loading screen shown while the (mock) AI builds the program.
class GenerationScreen extends ConsumerStatefulWidget {
  final String domainId;
  const GenerationScreen({super.key, required this.domainId});

  @override
  ConsumerState<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends ConsumerState<GenerationScreen> {
  final _steps = const [
    'Analyse de ton domaine…',
    'Conception des modules…',
    'Préparation des exercices…',
    'Personnalisation finale…',
  ];
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final domain = kDomains.firstWhere(
      (d) => d.id == widget.domainId,
      orElse: () => kDomains.first,
    );

    // Cycle through the status messages for a lively feel.
    for (var i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      setState(() => _stepIndex = i);
    }

    await ref.read(programControllerProvider.notifier).generate(domain.label);
    if (!mounted) return;
    context.go('/program');
  }

  @override
  Widget build(BuildContext context) {
    final domain = kDomains.firstWhere(
      (d) => d.id == widget.domainId,
      orElse: () => kDomains.first,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'domain-${domain.id}',
                child: _PulsingLoader(color: domain.color, icon: domain.icon),
              ),
              const SizedBox(height: 40),
              const Text(
                'Création de ton\nprogramme personnalisé…',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Text(
                  _steps[_stepIndex],
                  key: ValueKey(_stepIndex),
                  style: TextStyle(fontSize: 15, color: AppColors.inkSoft),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A custom rotating, pulsing loader (programmatic — no asset needed, but easy
/// to swap for a Lottie animation later).
class _PulsingLoader extends StatefulWidget {
  final Color color;
  final IconData icon;
  const _PulsingLoader({required this.color, required this.icon});

  @override
  State<_PulsingLoader> createState() => _PulsingLoaderState();
}

class _PulsingLoaderState extends State<_PulsingLoader>
    with TickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _spin.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _spin,
            builder: (_, _) => Transform.rotate(
              angle: _spin.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(160, 160),
                painter: _ArcPainter(widget.color),
              ),
            ),
          ),
          ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.08).animate(
              CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: 44, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  _ArcPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0), color, color],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(rect);
    canvas.drawArc(rect.deflate(6), 0, math.pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.color != color;
}
