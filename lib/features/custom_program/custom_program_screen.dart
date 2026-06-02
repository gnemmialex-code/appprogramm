import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_providers.dart';
import '../../ui/animations/fade_slide.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';

/// "Mon propre programme" — the user describes any theme they want to learn and
/// (mock) AI builds a complete, structured program for it.
class CustomProgramScreen extends ConsumerStatefulWidget {
  const CustomProgramScreen({super.key});

  @override
  ConsumerState<CustomProgramScreen> createState() =>
      _CustomProgramScreenState();
}

class _CustomProgramScreenState extends ConsumerState<CustomProgramScreen> {
  final _themeCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  bool _generating = false;

  static const _examples = [
    'Parler en public',
    'Finances personnelles',
    'Apprendre la guitare',
    'Gestion du temps',
    'Bases du dessin',
    'Méditation',
  ];

  @override
  void dispose() {
    _themeCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final theme = _themeCtrl.text.trim();
    if (theme.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _generating = true);

    // Let the multi-AI animation play for a moment, then build.
    await Future.delayed(const Duration(milliseconds: 2600));
    await ref.read(programControllerProvider.notifier).generate(
          theme,
          objectif: _goalCtrl.text.trim().isEmpty ? null : _goalCtrl.text.trim(),
        );
    if (!mounted) return;
    context.go('/program');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon propre programme'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _generating ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _generating
              ? _GeneratingView(theme: _themeCtrl.text.trim())
              : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final canGenerate = _themeCtrl.text.trim().isNotEmpty;
    return ListView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(20),
      children: [
        FadeSlideIn(
          child: SoftCard(
            gradient: AppColors.brandGradient,
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Décris ce que tu veux apprendre. Nos IA construisent un '
                    'programme complet, structuré et précis rien que pour toi.',
                    style: const TextStyle(color: Colors.white, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text('Ta thématique',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: TextField(
            controller: _themeCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Ex : prendre la parole en public',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ex in _examples)
              GestureDetector(
                onTap: () => setState(() => _themeCtrl.text = ex),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lavender.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(ex,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        SoftCard(
          color: AppColors.sky.withValues(alpha: 0.16),
          child: Row(
            children: [
              const Icon(Icons.stairs_rounded, color: AppColors.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ton programme inclura automatiquement 3 niveaux : '
                  'Niveau 1 facile, puis 2 et 3 de plus en plus intenses.',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.ink, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text('Ton objectif',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            Text('(facultatif)',
                style: TextStyle(fontSize: 13, color: AppColors.inkSoft)),
          ],
        ),
        const SizedBox(height: 10),
        SoftCard(
          child: TextField(
            controller: _goalCtrl,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Ex : tenir un discours de 5 min sans notes d\'ici 1 mois',
            ),
          ),
        ),
        const SizedBox(height: 28),
        GradientButton(
          label: 'Générer mon programme',
          icon: Icons.auto_awesome_rounded,
          onPressed: canGenerate ? _generate : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Animated "multiple AIs at work" view shown during generation.
class _GeneratingView extends StatefulWidget {
  final String theme;
  const _GeneratingView({required this.theme});

  @override
  State<_GeneratingView> createState() => _GeneratingViewState();
}

class _GeneratingViewState extends State<_GeneratingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  final _agents = const [
    ('🧠', 'IA Architecte', 'structure tes chapitres…'),
    ('✍️', 'IA Pédagogue', 'rédige exercices & quiz…'),
    ('🎯', 'IA Coach', 'personnalise ton plan…'),
    ('✨', 'Finalisation', 'assemble ton programme…'),
  ];
  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 620), (t) {
      if (!mounted) return;
      setState(() => _step = (_step + 1).clamp(0, _agents.length - 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('gen'),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RotationTransition(
                  turns: _spin,
                  child: const SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor:
                          AlwaysStoppedAnimation(AppColors.brandStart),
                      backgroundColor: AppColors.line,
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: AppColors.brandGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 36),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Création de ton programme\n« ${widget.theme} »',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          ...List.generate(_agents.length, (i) {
            final (emoji, name, action) = _agents[i];
            final done = i < _step;
            final active = i == _step;
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: i <= _step ? 1 : 0.35,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: done
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 22)
                          : Text(emoji,
                              style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 15,
                            height: 1.3,
                          ),
                          children: [
                            TextSpan(
                              text: '$name ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? AppColors.brandStart
                                    : AppColors.ink,
                              ),
                            ),
                            TextSpan(
                              text: action,
                              style: TextStyle(color: AppColors.inkSoft),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
