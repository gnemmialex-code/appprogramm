import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/adaptive/adaptive.dart';
import '../../core/models/content_models.dart';
import '../../state/app_providers.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';
import '../exercises/exercise_widgets.dart';
import '../quiz/quiz_runner.dart';

/// A single chapter, learned as a **vertical TikTok-style feed** (text):
/// swipe up = next card, swipe down = previous. Cards are: intro, optional
/// adaptive reinforcement, each step, exercises, and the mini-quiz.
class ModuleScreen extends ConsumerStatefulWidget {
  final int index;
  const ModuleScreen({super.key, required this.index});

  @override
  ConsumerState<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends ConsumerState<ModuleScreen> {
  final _controller = PageController();
  int _page = 0;
  final DateTime _openedAt = DateTime.now();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish(String moduleId) {
    final seconds =
        DateTime.now().difference(_openedAt).inSeconds.clamp(0, 30 * 60);
    final notifier = ref.read(progressControllerProvider.notifier);
    notifier.recordModuleTime(moduleId, seconds);
    notifier.completeModule(moduleId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Module terminé ! 🎉'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final program = ref.watch(programControllerProvider);
    if (program == null || widget.index >= program.modules.length) {
      return const Scaffold(body: Center(child: Text('Module introuvable')));
    }
    final module = program.modules[widget.index];
    final hasQuiz = module.quiz.isNotEmpty;
    final reinforce = reinforcementFor(
      program,
      ref.watch(progressControllerProvider),
      widget.index,
    );

    final pages = <Widget>[
      _IntroCard(module: module),
      if (reinforce.isNotEmpty) _ReinforcementCard(topics: reinforce),
      ...module.steps.map((s) => _StepCard(step: s, onValidate: _next)),
      _ExercisesCard(
        module: module,
        reinforcement: reinforcementExercises(reinforce),
        hasQuiz: hasQuiz,
        onNext: hasQuiz ? _next : () => _finish(module.id),
      ),
      if (hasQuiz)
        _QuizCard(
          module: module,
          onFinish: (score, total) {
            ref
                .read(progressControllerProvider.notifier)
                .recordModuleQuiz(module.id, score, total);
            _finish(module.id);
          },
        ),
    ];

    final pad = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Vertical, snapping TikTok-style feed.
          PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            onPageChanged: (p) => setState(() => _page = p),
            itemCount: pages.length,
            itemBuilder: (_, i) => pages[i],
          ),

          // Top overlay: close button + linear progress + counter.
          Positioned(
            top: pad.top + 6,
            left: 10,
            right: 10,
            child: Row(
              children: [
                _CircleButton(
                  icon: Icons.close_rounded,
                  onTap: () => context.pop(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_page + 1) / pages.length,
                      minHeight: 6,
                      backgroundColor: Colors.black.withValues(alpha: 0.12),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.brandStart),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${_page + 1}/${pages.length}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          ),

          // Right-side position dots.
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(pages.length, (i) {
                  final on = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    width: 6,
                    height: on ? 18 : 6,
                    decoration: BoxDecoration(
                      color: on
                          ? AppColors.brandStart
                          : Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Swipe-up hint on the very first card.
          if (_page == 0)
            Positioned(
              bottom: pad.bottom + 14,
              left: 0,
              right: 0,
              child: const _SwipeHint(),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.20),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _SwipeHint extends StatefulWidget {
  const _SwipeHint();

  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => Transform.translate(
            offset: Offset(0, -6 * _c.value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_arrow_up_rounded,
                    color: AppColors.inkSoft.withValues(alpha: 0.8)),
                Text('Glisse vers le haut',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkSoft.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A flat white button used on the coloured step cards.
class _WhiteButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color textColor;
  const _WhiteButton({
    required this.label,
    required this.onPressed,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 10),
              ],
              Text(label,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cards
// ---------------------------------------------------------------------------

/// Light, scrollable wrapper for the non-immersive cards (intro / reinforce /
/// exercises). Content scrolls; an action button advances the feed.
class _SheetCard extends StatelessWidget {
  final Widget child;
  const _SheetCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 52, 20, pad.bottom + 16),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final Module module;
  const _IntroCard({required this.module});

  @override
  Widget build(BuildContext context) {
    final lvl = (module.level - 1).clamp(0, 2);
    return _SheetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BadgeChip(
            label: const ['Facile', 'Intermédiaire', 'Avancé'][lvl],
            icon: Icons.stairs_rounded,
            color: const [AppColors.mint, AppColors.sun, AppColors.rose][lvl],
          ),
          const SizedBox(height: 14),
          Text(module.title,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, height: 1.1)),
          const SizedBox(height: 14),
          SoftCard(
            color: AppColors.lavender.withValues(alpha: 0.16),
            child: Text(module.content,
                style: const TextStyle(fontSize: 16, height: 1.5)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.swipe_vertical_rounded,
                  color: AppColors.inkSoft, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Glisse vers le haut pour apprendre, étape par étape.',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.inkSoft),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Adaptive reinforcement card (revisits weak subjects).
class _ReinforcementCard extends StatelessWidget {
  final List<ReinforcementTopic> topics;
  const _ReinforcementCard({required this.topics});

  @override
  Widget build(BuildContext context) {
    return _SheetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TintedIcon(
                  icon: Icons.replay_rounded, color: AppColors.peach, size: 52),
              const SizedBox(width: 14),
              const Expanded(
                child: Text('On y revient un instant',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Ton parcours s\'adapte à toi : un rappel des sujets sur lesquels '
            'tu as pris ton temps, pour bien les ancrer.',
            style:
                TextStyle(fontSize: 15, color: AppColors.inkSoft, height: 1.4),
          ),
          const SizedBox(height: 16),
          ...topics.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SoftCard(
                color: AppColors.peach.withValues(alpha: 0.14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(t.subject,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                        BadgeChip(
                            label: t.reason,
                            icon: Icons.bolt_rounded,
                            color: AppColors.peach),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(t.recap, style: const TextStyle(height: 1.4)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('Glisse vers le haut pour continuer ↑',
                style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
          ),
        ],
      ),
    );
  }
}

/// Immersive, full-bleed learning step (the TikTok-style cards).
class _StepCard extends StatelessWidget {
  final ProgramStep step;
  final VoidCallback onValidate;
  const _StepCard({required this.step, required this.onValidate});

  @override
  Widget build(BuildContext context) {
    final color = colorForStep(step.type);
    final deep = Color.lerp(color, Colors.black, 0.55)!;
    final pad = MediaQuery.of(context).padding;
    final label = switch (step.type) {
      StepType.audio => 'Écoute',
      StepType.reflection => 'Réflexion',
      StepType.action => 'Action',
      StepType.text => 'Lecture',
    };

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, deep],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(22, 56, 22, pad.bottom + 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconForStep(step.type),
                        size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      Text(step.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.1)),
                      const SizedBox(height: 14),
                      Text(step.body,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 17,
                              height: 1.5)),
                      const SizedBox(height: 20),
                      StepInteractive(type: step.type),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _WhiteButton(
                label: 'Valider',
                icon: Icons.check_rounded,
                textColor: deep,
                onPressed: onValidate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interactive exercises (incl. adaptive targeted ones), then continue.
class _ExercisesCard extends StatelessWidget {
  final Module module;
  final List<Exercise> reinforcement;
  final bool hasQuiz;
  final VoidCallback onNext;
  const _ExercisesCard({
    required this.module,
    this.reinforcement = const [],
    required this.hasQuiz,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Exercices',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Mets en pratique ce que tu viens de voir.',
              style: TextStyle(color: AppColors.inkSoft)),
          const SizedBox(height: 16),
          if (reinforcement.isNotEmpty) ...[
            Row(
              children: const [
                Icon(Icons.bolt_rounded, color: AppColors.peach),
                SizedBox(width: 6),
                Text('Renforcement ciblé',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Des exercices en plus sur les sujets où tu as pris ton temps.',
                style: TextStyle(fontSize: 13, color: AppColors.inkSoft)),
            const SizedBox(height: 12),
            ...reinforcement.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ExerciseTile(exercise: e),
              ),
            ),
            const Divider(height: 28, color: AppColors.line),
          ],
          ...module.exercises.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ExerciseTile(exercise: e),
            ),
          ),
          const SizedBox(height: 8),
          GradientButton(
            label: hasQuiz ? 'Passer au quiz' : 'Terminer le module',
            icon: hasQuiz ? Icons.quiz_rounded : Icons.flag_rounded,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final Module module;
  final void Function(int score, int total) onFinish;
  const _QuizCard({required this.module, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 52, 20, pad.bottom + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mini-quiz du chapitre',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Vérifie ce que tu as retenu pour valider le chapitre.',
                style: TextStyle(color: AppColors.inkSoft)),
            const SizedBox(height: 12),
            Expanded(
              child: QuizRunner(
                questions: module.quiz,
                finishLabel: 'Terminer le chapitre',
                onFinished: onFinish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
