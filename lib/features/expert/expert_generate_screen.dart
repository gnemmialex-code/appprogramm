import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_providers.dart';
import '../../ui/theme/app_colors.dart';
import '../domain_selection/domains_data.dart';

class ExpertGenerateScreen extends ConsumerStatefulWidget {
  final String domainId;
  final String? objectif;
  const ExpertGenerateScreen({
    super.key,
    required this.domainId,
    this.objectif,
  });

  @override
  ConsumerState<ExpertGenerateScreen> createState() =>
      _ExpertGenerateScreenState();
}

class _ExpertGenerateScreenState extends ConsumerState<ExpertGenerateScreen> {
  final _steps = const [
    'Analyse des frameworks de référence…',
    'Construction des 15 chapitres experts…',
    'Intégration des nuances avancées…',
    'Calibrage du niveau professionnel…',
    'Finalisation du programme expert…',
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
    for (var i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 720));
      if (!mounted) return;
      setState(() => _stepIndex = i);
    }
    await ref
        .read(expertProgramControllerProvider.notifier)
        .generate(domain.label, objectif: widget.objectif);
    if (!mounted) return;
    context.go('/expert-program');
  }

  @override
  Widget build(BuildContext context) {
    final domain = kDomains.firstWhere(
      (d) => d.id == widget.domainId,
      orElse: () => kDomains.first,
    );

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ExpertLoader(color: domain.color, icon: domain.icon),
              const SizedBox(height: 40),
              const Text(
                '🎓 Mode Expert',
                style: TextStyle(
                  color: AppColors.deepPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Création de ton\nprogramme expert…',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Text(
                  _steps[_stepIndex],
                  key: ValueKey(_stepIndex),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpertLoader extends StatefulWidget {
  final Color color;
  final IconData icon;
  const _ExpertLoader({required this.color, required this.icon});

  @override
  State<_ExpertLoader> createState() => _ExpertLoaderState();
}

class _ExpertLoaderState extends State<_ExpertLoader>
    with TickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
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
                painter: _ExpertArcPainter(AppColors.deepPurple),
              ),
            ),
          ),
          ScaleTransition(
            scale: Tween(
              begin: 0.90,
              end: 1.10,
            ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.deepPurple.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpertArcPainter extends CustomPainter {
  final Color color;
  _ExpertArcPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0), color, Colors.white],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawArc(rect.deflate(6), 0, math.pi * 1.8, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ExpertArcPainter old) => old.color != color;
}
