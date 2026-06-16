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
        ExerciseTile,
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

  // 7-second minimum read-time lock per page.
  bool _canSwipe = false;
  int _countdown = 7;
  Timer? _swipeTimer;
  Timer? _cntTimer;
  // Indices of pages that are never locked (quiz, quote, etc.)
  final Set<int> _freePages = {};

  void _kickTimer(int page) {
    _swipeTimer?.cancel();
    _cntTimer?.cancel();
    if (_freePages.contains(page)) {
      if (mounted) setState(() { _canSwipe = true; _countdown = 0; });
      return;
    }
    if (mounted) setState(() { _canSwipe = false; _countdown = 7; });
    _swipeTimer = Timer(const Duration(seconds: 7), () {
      if (mounted) setState(() => _canSwipe = true);
    });
    _cntTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() { if (_countdown > 0) _countdown--; });
      if (_countdown <= 0) t.cancel();
    });
  }

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
    _swipeTimer?.cancel();
    _cntTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _showTimerSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _TimerToggleSheet(
        timerOn: _timerOn,
        onToggle: (enabled) {
          ref.read(appSettingsProvider.notifier).setChapterTimer(enabled);
          setState(() {
            _timerOn = enabled;
            if (enabled) {
              final avg =
                  ref.read(dailyAvailabilityProvider).averageActiveMinutes;
              final minutes =
                  tierMinutesPerChapter(tierFromMinutes(avg));
              _totalSeconds = minutes * 60;
              _remaining = _totalSeconds;
              _timer?.cancel();
              _timer = Timer.periodic(const Duration(seconds: 1), (_) {
                if (!mounted) return;
                if (_remaining <= 0) return;
                setState(() => _remaining--);
              });
            } else {
              _timer?.cancel();
              _timer = null;
            }
          });
        },
      ),
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
        onNext: _next,
      )),
      if (hasQuiz)
        par(_QuizCard(
          module: module,
          onFinish: (score, total) {
            ref
                .read(progressControllerProvider.notifier)
                .recordModuleQuiz(module.id, score, total);
            _next();
          },
        )),
      par(_QuoteCard(
        domain: program.domain,
        onFinish: () => _finish(module.id),
      )),
    ];

    // Mark quiz and quote pages as free (no 7-second lock).
    _freePages
      ..clear()
      ..add(pages.length - 1); // quote (always last)
    if (hasQuiz) _freePages.add(pages.length - 2); // quiz

    // Start the first-page timer once.
    if (!_canSwipe && _countdown == 7 && _page == 0 && _swipeTimer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _kickTimer(0));
    }

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
            physics: _canSwipe
                ? const PageScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            onPageChanged: (p) {
              setState(() => _page = p);
              _kickTimer(p);
            },
            itemCount: pages.length,
            itemBuilder: (_, i) => pages[i],
          ),

          // Full-screen swipe-up overlay — works from anywhere on screen.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) < -400 && _canSwipe) {
                  _next();
                }
              },
              child: const SizedBox.expand(),
            ),
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
                if (!_canSwipe && !_freePages.contains(_page)) ...[
                  const SizedBox(width: 8),
                  _LockPill(countdown: _countdown),
                ],
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showTimerSheet(context, ref),
                  child: _timerOn
                      ? _TimerPill(remaining: _remaining, total: _totalSeconds)
                      : _TimerOffPill(),
                ),
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
  final VoidCallback onNext;
  const _ExercisesCard({
    required this.module,
    this.reinforcement = const [],
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
            label: 'Continuer',
            icon: Icons.arrow_forward_rounded,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

/// Small lock indicator shown when the 7-second read timer is active.
class _LockPill extends StatelessWidget {
  final int countdown;
  const _LockPill({required this.countdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline_rounded, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '${countdown}s',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
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

// ---------------------------------------------------------------------------
// Timer toggle UI
// ---------------------------------------------------------------------------

/// Small pill shown in the top bar when the chapter timer is disabled.
class _TimerOffPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_off_outlined, size: 14,
              color: Colors.white.withValues(alpha: 0.55)),
          const SizedBox(width: 5),
          Text('Chrono',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.55))),
        ],
      ),
    );
  }
}

class _TimerToggleSheet extends StatelessWidget {
  final bool timerOn;
  final ValueChanged<bool> onToggle;
  const _TimerToggleSheet({required this.timerOn, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Chronomètre de chapitre',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'Activer le chrono te donne un rythme et une sensation d\'urgence productive.',
              style: TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _TimerOption(
              icon: Icons.timer_rounded,
              label: 'Avec chrono',
              description: 'Un compte à rebours visible adapté à ton rythme',
              selected: timerOn,
              color: AppColors.brandStart,
              onTap: () { Navigator.pop(context); onToggle(true); },
            ),
            const SizedBox(height: 10),
            _TimerOption(
              icon: Icons.timer_off_rounded,
              label: 'Sans chrono',
              description: 'Avance à ton propre rythme, sans contrainte de temps',
              selected: !timerOn,
              color: AppColors.inkSoft,
              onTap: () { Navigator.pop(context); onToggle(false); },
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TimerOption({
    required this.icon, required this.label, required this.description,
    required this.selected, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.10) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.black.withValues(alpha: 0.08),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.15)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: selected ? color : AppColors.inkSoft, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: selected ? color : AppColors.ink)),
                  const SizedBox(height: 2),
                  Text(description,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.inkSoft)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Domain-specific closing quotes
// ---------------------------------------------------------------------------

const _kDomainQuotes = <String, ({String text, String author})>{
  // Technology / Programming
  'programming': (
    text: 'La simplicité est la sophistication suprême.',
    author: 'Leonardo da Vinci',
  ),
  'code': (
    text: 'Tout code que tu n\'as pas écrit est du code que tu n\'as pas à maintenir.',
    author: 'Jeff Atwood',
  ),
  'web': (
    text: 'Le web est plus un phénomène social que technique.',
    author: 'Tim Berners-Lee',
  ),
  'data': (
    text: 'Les données sont le nouveau pétrole. Mais brutes, elles ne valent rien.',
    author: 'Clive Humby',
  ),
  'ai': (
    text: 'L\'intelligence artificielle est la nouvelle électricité.',
    author: 'Andrew Ng',
  ),
  'cybersecurity': (
    text: 'La sécurité n\'est pas un produit, c\'est un processus.',
    author: 'Bruce Schneier',
  ),
  // Business & Finance
  'business': (
    text: 'Ton meilleur investissement, c\'est toi-même.',
    author: 'Warren Buffett',
  ),
  'finance': (
    text: 'Ne travaille pas pour l\'argent — fais-le travailler pour toi.',
    author: 'Robert Kiyosaki',
  ),
  'entrepreneurship': (
    text: 'Commencer, c\'est avoir à moitié réussi.',
    author: 'Proverbe',
  ),
  'marketing': (
    text: 'Le marketing est une bataille d\'idées, pas de produits.',
    author: 'Al Ries',
  ),
  // Mindfulness & Well-being
  'mindfulness': (
    text: 'L\'instant présent est le seul moment disponible pour être en vie.',
    author: 'Thich Nhat Hanh',
  ),
  'wellbeing': (
    text: 'Prendre soin de soi n\'est pas un luxe, c\'est une nécessité.',
    author: 'Audre Lorde',
  ),
  'meditation': (
    text: 'Le calme est une superforce.',
    author: 'Anonyme',
  ),
  // Fitness & Health
  'fitness': (
    text: 'Un corps sain héberge un esprit sain.',
    author: 'Juvénal',
  ),
  'nutrition': (
    text: 'Que ton alimentation soit ta première médecine.',
    author: 'Hippocrate',
  ),
  // Languages & Communication
  'language': (
    text: 'Une autre langue, c\'est une autre âme.',
    author: 'Charlemagne',
  ),
  'communication': (
    text: 'La façon dont tu parles à toi-même compte plus que tout.',
    author: 'Lisa M. Hayes',
  ),
  // Science & Math
  'science': (
    text: 'La science, c\'est d\'abord regarder le monde tel qu\'il est.',
    author: 'Richard Feynman',
  ),
  'mathematics': (
    text: 'Les mathématiques sont la langue dans laquelle Dieu a écrit l\'univers.',
    author: 'Galilée',
  ),
  // Arts & Creativity
  'art': (
    text: 'La créativité, c\'est l\'intelligence qui s\'amuse.',
    author: 'Albert Einstein',
  ),
  'music': (
    text: 'La musique donne une âme à nos cœurs et des ailes à la pensée.',
    author: 'Platon',
  ),
  'writing': (
    text: 'Écrire, c\'est réfléchir à voix haute sur la page.',
    author: 'E.M. Forster',
  ),
  // Philosophy & Personal Growth
  'philosophy': (
    text: 'Connais-toi toi-même.',
    author: 'Socrate',
  ),
  'psychology': (
    text: 'Ce que tu résistes persiste, ce que tu acceptes se transforme.',
    author: 'Carl Jung',
  ),
  'productivity': (
    text: 'Ce n\'est pas le temps qui manque, c\'est la direction.',
    author: 'Sénèque',
  ),
  'leadership': (
    text: 'Un leader est quelqu\'un qui connaît le chemin, le fait et le montre.',
    author: 'John C. Maxwell',
  ),
};

({String text, String author}) _quoteFor(String domain) {
  // Exact match first, then partial match on the domain key.
  final lower = domain.toLowerCase();
  if (_kDomainQuotes.containsKey(lower)) return _kDomainQuotes[lower]!;
  for (final key in _kDomainQuotes.keys) {
    if (lower.contains(key) || key.contains(lower)) {
      return _kDomainQuotes[key]!;
    }
  }
  return (
    text: 'Le savoir est la seule richesse qui grandit quand on la partage.',
    author: 'Proverbe',
  );
}

/// Closing card shown at the end of every chapter — immersive, gradient
/// background, a domain-relevant quote, and the "Complete" button.
class _QuoteCard extends StatefulWidget {
  final String domain;
  final VoidCallback onFinish;
  const _QuoteCard({required this.domain, required this.onFinish});

  @override
  State<_QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<_QuoteCard> with TickerProviderStateMixin {
  late final AnimationController _grad = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat(reverse: true);

  late final AnimationController _blobs = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void dispose() {
    _grad.dispose();
    _blobs.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quote = _quoteFor(widget.domain);
    final pad = MediaQuery.of(context).padding;

    return AnimatedBuilder(
      animation: Listenable.merge([_grad, _blobs, _enter]),
      builder: (ctx, _) {
        final g = _grad.value;
        final fade = CurvedAnimation(parent: _enter, curve: Curves.easeOut).value;
        final slide = (1.0 - fade) * 40;

        // Calm deep-blue/indigo palette for the closing card.
        final base = HSLColor.fromAHSL(1, 235, 0.55, 0.36);
        final top = base
            .withLightness((base.lightness + 0.12 * g).clamp(0.0, 1.0))
            .toColor();
        final bottom =
            base.withLightness((base.lightness - 0.18).clamp(0.0, 1.0)).toColor();

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.6 + 0.4 * g, -1),
              end: Alignment(0.6 - 0.3 * g, 1),
              colors: [top, bottom],
            ),
          ),
          child: CustomPaint(
            painter: _BlobPainter(t: _blobs.value),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(28, pad.top + 60, 28, pad.bottom + 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Quotation mark decoration
                    Opacity(
                      opacity: fade,
                      child: Transform.translate(
                        offset: Offset(0, slide),
                        child: Text(
                          '“',
                          style: TextStyle(
                            fontSize: 96,
                            height: 0.6,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quote text
                    Opacity(
                      opacity: fade,
                      child: Transform.translate(
                        offset: Offset(0, slide * 0.8),
                        child: Text(
                          quote.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Author
                    Opacity(
                      opacity: fade * 0.8,
                      child: Transform.translate(
                        offset: Offset(0, slide * 0.6),
                        child: Text(
                          '— ${quote.author}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Finish button
                    Opacity(
                      opacity: fade,
                      child: Transform.translate(
                        offset: Offset(0, slide * 0.4),
                        child: SizedBox(
                          width: double.infinity,
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              onTap: widget.onFinish,
                              borderRadius: BorderRadius.circular(18),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 17),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: bottom,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Terminer le chapitre',
                                      style: TextStyle(
                                        color: bottom,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
