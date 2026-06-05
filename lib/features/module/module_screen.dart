import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/adaptive/adaptive.dart';
import '../../core/ai/generator.dart' show tierFromMinutes, tierMinutesPerChapter;
import '../../core/models/content_models.dart';
import '../../core/models/note_model.dart';
import '../../state/app_providers.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';
import '../exercises/exercise_widgets.dart'
    show
        ActionTimerWidget,
        DarkStepInteractive,
        ExerciseTile,
        StepDemoWidget,
        StepInteractive,
        StepQuestionWidget,
        colorForStep,
        iconForStep,
        labelForStep;
import '../notes/note_widgets.dart';
import '../quiz/quiz_runner.dart';

/// A single chapter, learned as a **vertical TikTok-style feed** (text):
/// swipe up = next card, swipe down = previous. Cards are: intro, optional
/// adaptive reinforcement, each step, exercises, and the mini-quiz.
class ModuleScreen extends ConsumerStatefulWidget {
  final int index;

  /// If provided, uses this program instead of the one from the provider.
  final Program? programOverride;

  /// True when displaying an expert-mode chapter (affects note location).
  final bool isExpert;
  const ModuleScreen({
    super.key,
    required this.index,
    this.programOverride,
    this.isExpert = false,
  });

  @override
  ConsumerState<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends ConsumerState<ModuleScreen> {
  final _controller = PageController();
  int _page = 0;
  final DateTime _openedAt = DateTime.now();

  // Optional chapter timer (enabled in settings for a sense of urgency).
  Timer? _timer;
  bool _timerOn = false;
  int _totalSeconds = 0;
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    // Start a countdown sized to the user's per-chapter pace, if enabled.
    if (ref.read(appSettingsProvider).chapterTimer) {
      final avg = ref.read(dailyAvailabilityProvider).averageActiveMinutes;
      final minutes = tierMinutesPerChapter(tierFromMinutes(avg));
      _timerOn = true;
      _totalSeconds = minutes * 60;
      _remaining = _totalSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (_remaining <= 0) return;
        setState(() => _remaining--);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    final seconds = DateTime.now()
        .difference(_openedAt)
        .inSeconds
        .clamp(0, 30 * 60);
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
    final program =
        widget.programOverride ?? ref.watch(programControllerProvider);
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

    // Helper to build a note location for this module/context.
    NoteLocation loc(String contextType, [String? stepTitle]) => NoteLocation(
      programDomain: program.domain,
      moduleTitle: module.title,
      moduleIndex: widget.index,
      stepTitle: stepTitle,
      contextType: contextType,
      isExpert: widget.isExpert,
    );

    // Build pages with scroll-parallax wrappers.
    // pi tracks each page's index so _PageParallax can compute its offset.
    var pi = 0;
    _PageParallax par(Widget w) =>
        _PageParallax(controller: _controller, index: pi++, child: w);

    final pages = <Widget>[
      par(_IntroCard(module: module)),
      if (reinforce.isNotEmpty) par(_ReinforcementCard(topics: reinforce)),
      ...module.steps.map((s) {
        final idx = pi++;
        return _StepCard(
          step: s,
          onValidate: _next,
          pageController: _controller,
          pageIndex: idx,
        );
      }),
      par(_ExercisesCard(
        module: module,
        reinforcement: reinforcementExercises(reinforce),
        hasQuiz: hasQuiz,
        onNext: hasQuiz ? _next : () => _finish(module.id),
      )),
      if (hasQuiz)
        par(_QuizCard(
          module: module,
          onFinish: (score, total) {
            ref
                .read(progressControllerProvider.notifier)
                .recordModuleQuiz(module.id, score, total);
            _finish(module.id);
          },
        )),
    ];

    // Note locations parallel to pages (null = page has no note support).
    final noteLocations = <NoteLocation?>[
      loc('intro'),
      if (reinforce.isNotEmpty) null,
      ...module.steps.map((s) => loc('step', s.title)),
      loc('exercises'),
      if (hasQuiz) null,
    ];

    // Resolve note state for the current page.
    ref.watch(notesProvider);
    final currentNoteLoc =
        _page < noteLocations.length ? noteLocations[_page] : null;
    final hasNote = currentNoteLoc != null &&
        ref.read(notesProvider.notifier).noteForLocation(currentNoteLoc) !=
            null;

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

          // Top overlay: close · note · progress · counter.
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
                const SizedBox(width: 8),
                // Note button — top-left, adapts to current page.
                Tooltip(
                  message: 'Note',
                  preferBelow: true,
                  child: GestureDetector(
                    onTap: currentNoteLoc != null
                        ? () => openNoteEditor(context, ref, currentNoteLoc)
                        : null,
                    child: Opacity(
                      opacity: currentNoteLoc != null ? 1.0 : 0.25,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              hasNote
                                  ? Icons.sticky_note_2_rounded
                                  : Icons.edit_note_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          if (hasNote)
                            Positioned(
                              right: 1,
                              top: 1,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: AppColors.brandStart,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_page + 1) / pages.length,
                      minHeight: 6,
                      backgroundColor: Colors.black.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.brandStart,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_page + 1}/${pages.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                if (_timerOn) ...[
                  const SizedBox(width: 10),
                  _TimerPill(remaining: _remaining, total: _totalSeconds),
                ],
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

/// Countdown chip shown at the top when the chapter timer is enabled. Goes
/// from calm → warning → urgent (pulsing) as time runs out, then "Temps écoulé".
class _TimerPill extends StatefulWidget {
  final int remaining;
  final int total;
  const _TimerPill({required this.remaining, required this.total});

  @override
  State<_TimerPill> createState() => _TimerPillState();
}

class _TimerPillState extends State<_TimerPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString();
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = widget.remaining <= 0;
    final frac = widget.total == 0 ? 0.0 : widget.remaining / widget.total;
    final urgent = elapsed || frac <= 0.2;

    final color = elapsed
        ? AppColors.danger
        : frac <= 0.2
        ? AppColors.danger
        : frac <= 0.5
        ? AppColors.sun
        : AppColors.brandStart;

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            elapsed ? Icons.timer_off_rounded : Icons.timer_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            elapsed ? 'Temps écoulé' : _fmt(widget.remaining),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );

    if (!urgent) return pill;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) =>
          Transform.scale(scale: 1 + 0.06 * _pulse.value, child: child),
      child: pill,
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
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppColors.inkSoft.withValues(alpha: 0.8),
                ),
                Text(
                  'Glisse vers le haut',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.inkSoft.withValues(alpha: 0.8),
                  ),
                ),
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
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scroll-parallax wrapper — wraps light cards (intro, exercises, quiz…).
// Content slides + fades in sync with the PageController scroll position.
// _StepCard handles its own internal parallax so it is NOT wrapped here.
// ---------------------------------------------------------------------------

class _PageParallax extends StatelessWidget {
  final Widget child;
  final PageController controller;
  final int index;
  const _PageParallax({
    required this.child,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, inner) {
        double off = 0;
        if (controller.hasClients && controller.position.haveDimensions) {
          off = (controller.page! - index).clamp(-1.0, 1.0);
        }
        return Transform.translate(
          offset: Offset(0, off * 72),
          child: Opacity(
            opacity: (1.0 - off.abs() * 0.60).clamp(0.18, 1.0),
            child: inner,
          ),
        );
      },
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Animated blob overlay for immersive step cards
// ---------------------------------------------------------------------------

class _BlobPainter extends CustomPainter {
  final double t;
  const _BlobPainter({required this.t});

  // (relX, relY, radius, phase, ampX, ampY)
  static const _specs = [
    (0.14, 0.22, 88.0, 0.00, 24.0, 30.0),
    (0.82, 0.12, 62.0, 0.33, 28.0, 18.0),
    (0.07, 0.74, 54.0, 0.60, 16.0, 26.0),
    (0.78, 0.80, 78.0, 0.15, 32.0, 16.0),
    (0.48, 0.44, 40.0, 0.80, 12.0, 22.0),
    (0.30, 0.88, 66.0, 0.45, 20.0, 14.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (rx, ry, radius, phase, ampX, ampY) in _specs) {
      final angle = (t + phase) * 2 * math.pi;
      final x = rx * size.width + math.cos(angle) * ampX;
      final y = ry * size.height + math.sin(angle * 0.73) * ampY;
      final alpha =
          0.07 + 0.06 * math.sin((t * 1.5 + phase) * 2 * math.pi);
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
      );
    }
  }

  @override
  bool shouldRepaint(_BlobPainter o) => o.t != t;
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
          Text(
            module.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            color: AppColors.lavender.withValues(alpha: 0.16),
            child: Text(
              module.content,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.swipe_vertical_rounded,
                color: AppColors.inkSoft,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Glisse vers le haut pour apprendre, étape par étape.',
                  style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
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
                icon: Icons.replay_rounded,
                color: AppColors.peach,
                size: 52,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'On y revient un instant',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Ton parcours s\'adapte à toi : un rappel des sujets sur lesquels '
            'tu as pris ton temps, pour bien les ancrer.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.inkSoft,
              height: 1.4,
            ),
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
                          child: Text(
                            t.subject,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        BadgeChip(
                          label: t.reason,
                          icon: Icons.bolt_rounded,
                          color: AppColors.peach,
                        ),
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
            child: Text(
              'Glisse vers le haut pour continuer ↑',
              style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

/// Immersive animated step card with scroll-parallax content.
/// Background (gradient + blobs) stays fixed while the content slides
/// in sync with the PageController, creating a depth effect.
class _StepCard extends StatefulWidget {
  final ProgramStep step;
  final VoidCallback onValidate;
  final PageController pageController;
  final int pageIndex;
  const _StepCard({
    required this.step,
    required this.onValidate,
    required this.pageController,
    required this.pageIndex,
  });

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> with TickerProviderStateMixin {
  late final AnimationController _grad = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat(reverse: true);

  late final AnimationController _blobs = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 11),
  )..repeat();

  bool _actionDone = false;

  bool get _canValidate =>
      widget.step.type != StepType.action || _actionDone;

  @override
  void dispose() {
    _grad.dispose();
    _blobs.dispose();
    super.dispose();
  }

  /// Page offset: 0 = this card is centred, ±1 = one page away.
  double get _pageOff {
    final ctrl = widget.pageController;
    if (!ctrl.hasClients || !ctrl.position.haveDimensions) return 0;
    return (ctrl.page! - widget.pageIndex).clamp(-1.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForStep(widget.step.type);
    final deep = Color.lerp(color, Colors.black, 0.58)!;
    final pad = MediaQuery.of(context).padding;
    final isAction = widget.step.type == StepType.action;

    // Merge all three animation sources so a single builder handles them all.
    return AnimatedBuilder(
      animation: Listenable.merge([_grad, _blobs, widget.pageController]),
      builder: (ctx, _) {
        final g = _grad.value;
        final off = _pageOff;

        final topColor = Color.lerp(
          color,
          HSLColor.fromColor(color)
              .withLightness(
                (HSLColor.fromColor(color).lightness + 0.10 * g)
                    .clamp(0.0, 1.0),
              )
              .toColor(),
          0.5,
        )!;

        // ── Background: NO transform — stays fixed during swipe ──
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 0.5 * g, -1.0 + 0.3 * g),
              end: Alignment(1.0 - 0.2 * g, 1.0 - 0.4 * g),
              colors: [topColor, deep],
            ),
          ),
          child: CustomPaint(
            painter: _BlobPainter(t: _blobs.value),
            // ── Content: parallax-shifted with the swipe ──
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(22, 58, 22, pad.bottom + 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge slides slightly (less than body)
                    Transform.translate(
                      offset: Offset(0, off * 45),
                      child: Opacity(
                        opacity: (1 - off.abs() * 0.9).clamp(0.0, 1.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                iconForStep(widget.step.type),
                                size: 15,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                labelForStep(widget.step.type),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Main scrollable content — full parallax
                    Expanded(
                      child: Transform.translate(
                        offset: Offset(0, off * 88),
                        child: Opacity(
                          opacity: (1 - off.abs() * 0.88).clamp(0.0, 1.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 14),
                                if (!isAction) ...[
                                  StepDemoWidget(type: widget.step.type),
                                  const SizedBox(height: 14),
                                ],
                                Text(
                                  widget.step.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 11),
                                Text(
                                  widget.step.body,
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.93),
                                    fontSize: 19,
                                    height: 1.5,
                                  ),
                                ),
                                if (widget.step.question != null) ...[
                                  const SizedBox(height: 20),
                                  StepQuestionWidget(
                                    question: widget.step.question!,
                                  ),
                                ],
                                const SizedBox(height: 20),
                                if (isAction)
                                  ActionTimerWidget(
                                    onComplete: () {
                                      if (mounted) {
                                        setState(() => _actionDone = true);
                                      }
                                    },
                                  )
                                else
                                  DarkStepInteractive(
                                    type: widget.step.type,
                                  ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Button — small parallax so it stays reachable
                    Transform.translate(
                      offset: Offset(0, off * 35),
                      child: AnimatedOpacity(
                        opacity: _canValidate ? 1.0 : 0.38,
                        duration: const Duration(milliseconds: 400),
                        child: IgnorePointer(
                          ignoring: !_canValidate,
                          child: _WhiteButton(
                            label: _canValidate
                                ? 'Valider'
                                : 'En attente du timer…',
                            icon: _canValidate
                                ? Icons.check_rounded
                                : Icons.timer_rounded,
                            textColor: Color.lerp(color, Colors.black, 0.58)!,
                            onPressed: widget.onValidate,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
          const Text(
            'Exercices',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Mets en pratique ce que tu viens de voir.',
            style: TextStyle(color: AppColors.inkSoft),
          ),
          const SizedBox(height: 16),
          if (reinforcement.isNotEmpty) ...[
            Row(
              children: const [
                Icon(Icons.bolt_rounded, color: AppColors.peach),
                SizedBox(width: 6),
                Text(
                  'Renforcement ciblé',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Des exercices en plus sur les sujets où tu as pris ton temps.',
              style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 12),
            ...reinforcement.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ExerciseTile(exercise: e),
              ),
            ),
            Divider(height: 28, color: AppColors.line),
          ],
          ...module.exercises.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ExerciseTile(exercise: e),
            ),
          ),
          const SizedBox(height: 4),
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
            const Text(
              'Mini-quiz du chapitre',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Vérifie ce que tu as retenu pour valider le chapitre.',
              style: TextStyle(color: AppColors.inkSoft),
            ),
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
