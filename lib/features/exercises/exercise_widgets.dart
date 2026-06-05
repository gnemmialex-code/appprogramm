import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/models/content_models.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';

IconData iconForStep(StepType type) => switch (type) {
  StepType.text => Icons.menu_book_rounded,
  StepType.reflection => Icons.edit_note_rounded,
  StepType.action => Icons.flash_on_rounded,
  StepType.fact => Icons.lightbulb_rounded,
  StepType.tip => Icons.tips_and_updates_rounded,
  StepType.challenge => Icons.emoji_events_rounded,
  StepType.framework => Icons.account_tree_rounded,
  StepType.research => Icons.biotech_rounded,
};

Color colorForStep(StepType type) => switch (type) {
  StepType.text => AppColors.mint,
  StepType.reflection => AppColors.lavender,
  StepType.action => AppColors.sun,
  StepType.fact => AppColors.sky,
  StepType.tip => AppColors.peach,
  StepType.challenge => AppColors.rose,
  StepType.framework => AppColors.deepPurple,
  StepType.research => AppColors.teal,
};

String labelForStep(StepType type) => switch (type) {
  StepType.text => 'Lecture',
  StepType.reflection => 'Réflexion',
  StepType.action => 'Action',
  StepType.fact => 'Le savais-tu ?',
  StepType.tip => 'Astuce',
  StepType.challenge => 'Défi',
  StepType.framework => 'Framework',
  StepType.research => 'Recherche',
};

// ---------------------------------------------------------------------------
// Step demo illustration — looping animation per step type (dark bg).
// Not shown for action steps (the timer IS the demo).
// ---------------------------------------------------------------------------

class StepDemoWidget extends StatefulWidget {
  final StepType type;
  const StepDemoWidget({super.key, required this.type});

  @override
  State<StepDemoWidget> createState() => _StepDemoWidgetState();
}

class _StepDemoWidgetState extends State<StepDemoWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    final dur = switch (widget.type) {
      StepType.challenge => const Duration(milliseconds: 700),
      StepType.reflection => const Duration(milliseconds: 1600),
      _ => const Duration(milliseconds: 2200),
    };
    _c = AnimationController(vsync: this, duration: dur)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == StepType.action) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = _c.value;
        final child = switch (widget.type) {
          StepType.text => _FloatEmoji(t: t, emoji: '📖'),
          StepType.fact => _GlowRing(t: t, emoji: '💡'),
          StepType.reflection => _WobbleEmoji(t: t, emoji: '✏️'),
          StepType.action => const SizedBox.shrink(),
          StepType.tip => _SpinScale(t: t, emoji: '⭐'),
          StepType.challenge => _FlickerScale(t: t, emoji: '🔥'),
          StepType.framework => _PulseOpacity(t: t, emoji: '🔗'),
          StepType.research => _SwingX(t: t, emoji: '🔍'),
        };
        return Center(child: SizedBox(width: 68, height: 68, child: child));
      },
    );
  }
}

// Shared circle container for illustrations
Widget _demoCircle(double alpha, Widget child) => Container(
  width: 68,
  height: 68,
  decoration: BoxDecoration(
    color: Colors.white.withValues(alpha: alpha),
    shape: BoxShape.circle,
  ),
  alignment: Alignment.center,
  child: child,
);

const _kEmojiStyle = TextStyle(fontSize: 30);

class _FloatEmoji extends StatelessWidget {
  final double t;
  final String emoji;
  const _FloatEmoji({required this.t, required this.emoji});
  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset(0, -5 * t + 2.5),
    child: _demoCircle(0.10 + 0.06 * t, Text(emoji, style: _kEmojiStyle)),
  );
}

class _GlowRing extends StatelessWidget {
  final double t;
  final String emoji;
  const _GlowRing({required this.t, required this.emoji});
  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 68 + 22 * t,
        height: 68 + 22 * t,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28 * (1 - t)),
            width: 2,
          ),
        ),
      ),
      _demoCircle(0.12 + 0.10 * t, Text(emoji, style: _kEmojiStyle)),
    ],
  );
}

class _WobbleEmoji extends StatelessWidget {
  final double t;
  final String emoji;
  const _WobbleEmoji({required this.t, required this.emoji});
  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -0.30 + 0.60 * t,
    child: _demoCircle(0.11, Text(emoji, style: _kEmojiStyle)),
  );
}

class _SpinScale extends StatelessWidget {
  final double t;
  final String emoji;
  const _SpinScale({required this.t, required this.emoji});
  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: t * math.pi * 0.5,
    child: Transform.scale(
      scale: 0.85 + 0.18 * t,
      child: _demoCircle(0.11 + 0.09 * t, Text(emoji, style: _kEmojiStyle)),
    ),
  );
}

class _FlickerScale extends StatelessWidget {
  final double t;
  final String emoji;
  const _FlickerScale({required this.t, required this.emoji});
  @override
  Widget build(BuildContext context) => Transform.scale(
    scale: 0.88 + 0.22 * t,
    child: _demoCircle(0.09 + 0.14 * t, Text(emoji, style: _kEmojiStyle)),
  );
}

class _PulseOpacity extends StatelessWidget {
  final double t;
  final String emoji;
  const _PulseOpacity({required this.t, required this.emoji});
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: 0.65 + 0.35 * t,
    child: Transform.scale(
      scale: 0.93 + 0.10 * t,
      child: _demoCircle(0.11, Text(emoji, style: _kEmojiStyle)),
    ),
  );
}

class _SwingX extends StatelessWidget {
  final double t;
  final String emoji;
  const _SwingX({required this.t, required this.emoji});
  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset(-9 + 18 * t, 0),
    child: _demoCircle(0.11, Text(emoji, style: _kEmojiStyle)),
  );
}

// ---------------------------------------------------------------------------
// Action step — auto-starting countdown timer (2 min). Calls [onComplete]
// when the ring fills. The Valider button in _StepCard listens to this.
// ---------------------------------------------------------------------------

class ActionTimerWidget extends StatefulWidget {
  final VoidCallback onComplete;
  static const _kTotal = 120; // 2 minutes
  const ActionTimerWidget({super.key, required this.onComplete});

  @override
  State<ActionTimerWidget> createState() => _ActionTimerWidgetState();
}

class _ActionTimerWidgetState extends State<ActionTimerWidget> {
  int _remaining = ActionTimerWidget._kTotal;
  bool _done = false;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          _remaining = 0;
          _done = true;
          _tick?.cancel();
          widget.onComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _fmt(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final progress =
        1.0 - _remaining / ActionTimerWidget._kTotal;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(140, 140),
                  painter: _TimerRingPainter(
                    progress: progress,
                    done: _done,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _done ? '✓' : _fmt(_remaining),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _done ? 44 : 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (!_done)
                      Text(
                        'Réalise l\'action',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.60),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (_done) ...[
            const SizedBox(height: 10),
            Text(
              'Bien joué ! Tu peux continuer 🎉',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final bool done;
  const _TimerRingPainter({required this.progress, required this.done});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 9;
    final bg = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(c, r, bg);
    if (progress > 0) {
      final arc = Paint()
        ..color = done ? const Color(0xFF4CAF50) : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(_TimerRingPainter o) =>
      o.progress != progress || o.done != done;
}

/// Renders the interactive component matching the step type.
class StepInteractive extends StatelessWidget {
  final StepType type;
  const StepInteractive({super.key, required this.type});

  @override
  Widget build(BuildContext context) => switch (type) {
    StepType.reflection => const _ReflectionField(),
    StepType.action => const _ActionCheck(),
    StepType.fact => const _FactCallout(),
    StepType.tip => const _TipConfirm(),
    StepType.challenge => const _ChallengeAccept(),
    StepType.framework => const _FrameworkCapture(),
    StepType.research => const _ResearchNote(),
    StepType.text => const SizedBox.shrink(),
  };
}

// ---------------------------------------------------------------------------
// Reflection — free-text journal
// ---------------------------------------------------------------------------

class _ReflectionField extends StatelessWidget {
  const _ReflectionField();

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.lavender.withValues(alpha: 0.12),
      child: TextField(
        maxLines: 4,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Écris ta réflexion ici…',
          hintStyle: TextStyle(color: AppColors.inkSoft),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action — checkbox confirm
// ---------------------------------------------------------------------------

class _ActionCheck extends StatefulWidget {
  const _ActionCheck();

  @override
  State<_ActionCheck> createState() => _ActionCheckState();
}

class _ActionCheckState extends State<_ActionCheck> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: _done
          ? AppColors.success.withValues(alpha: 0.14)
          : AppColors.sun.withValues(alpha: 0.16),
      onTap: () => setState(() => _done = !_done),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _done ? AppColors.success : Colors.transparent,
              border: Border.all(
                color: _done ? AppColors.success : AppColors.inkSoft,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: _done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _done ? 'Action réalisée — bravo ! 🎉' : 'Je l\'ai fait',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fact — "Did you know?" callout
// ---------------------------------------------------------------------------

class _FactCallout extends StatefulWidget {
  const _FactCallout();

  @override
  State<_FactCallout> createState() => _FactCalloutState();
}

class _FactCalloutState extends State<_FactCallout> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _confirmed = true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _confirmed
              ? AppColors.sky.withValues(alpha: 0.28)
              : AppColors.sky.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              _confirmed ? '🧠' : '💡',
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _confirmed
                    ? 'Bien noté ! Ce fait change la donne.'
                    : 'Touche pour marquer comme assimilé',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _confirmed ? AppColors.ink : AppColors.inkSoft,
                ),
              ),
            ),
            if (_confirmed)
              const Icon(
                Icons.verified_rounded,
                color: AppColors.sky,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tip — confirm you noted it
// ---------------------------------------------------------------------------

class _TipConfirm extends StatefulWidget {
  const _TipConfirm();

  @override
  State<_TipConfirm> createState() => _TipConfirmState();
}

class _TipConfirmState extends State<_TipConfirm> {
  bool _noted = false;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: _noted
          ? AppColors.success.withValues(alpha: 0.12)
          : AppColors.peach.withValues(alpha: 0.14),
      onTap: () => setState(() => _noted = true),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _noted ? AppColors.success : Colors.transparent,
              border: Border.all(
                color: _noted ? AppColors.success : AppColors.inkSoft,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: _noted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _noted ? 'Astuce enregistrée ✨' : 'Noté, je l\'applique',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Challenge — accept/complete the challenge
// ---------------------------------------------------------------------------

class _ChallengeAccept extends StatefulWidget {
  const _ChallengeAccept();

  @override
  State<_ChallengeAccept> createState() => _ChallengeAcceptState();
}

class _ChallengeAcceptState extends State<_ChallengeAccept> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _accepted
            ? AppColors.rose.withValues(alpha: 0.22)
            : AppColors.rose.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _accepted
              ? AppColors.rose.withValues(alpha: 0.6)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: GestureDetector(
        onTap: () => setState(() => _accepted = !_accepted),
        child: Row(
          children: [
            Text(_accepted ? '🏆' : '🎯', style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _accepted ? 'Défi accepté !' : 'Je relève le défi',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _accepted ? AppColors.rose : AppColors.ink,
                      fontSize: 15,
                    ),
                  ),
                  if (_accepted) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Engagement pris · bonne chance !',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Framework — map / schema the framework visually in free text
// ---------------------------------------------------------------------------

class _FrameworkCapture extends StatefulWidget {
  const _FrameworkCapture();

  @override
  State<_FrameworkCapture> createState() => _FrameworkCaptureState();
}

class _FrameworkCaptureState extends State<_FrameworkCapture> {
  bool _mapped = false;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.deepPurple.withValues(alpha: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_tree_rounded,
                color: AppColors.deepPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Schématise ce framework',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Dessine-le mentalement, puis décris ses composants ici…',
              hintStyle: TextStyle(color: AppColors.inkSoft, fontSize: 13),
              border: InputBorder.none,
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: (v) {
              if (v.length > 5 && !_mapped) setState(() => _mapped = true);
            },
          ),
          if (_mapped) ...[
            const SizedBox(height: 8),
            Text(
              'Framework schématisé ✓',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.deepPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Research — note the key finding
// ---------------------------------------------------------------------------

class _ResearchNote extends StatefulWidget {
  const _ResearchNote();

  @override
  State<_ResearchNote> createState() => _ResearchNoteState();
}

class _ResearchNoteState extends State<_ResearchNote> {
  bool _noted = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _noted = true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _noted
              ? AppColors.teal.withValues(alpha: 0.18)
              : AppColors.teal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _noted
                ? AppColors.teal.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(_noted ? '🔬' : '📄', style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _noted
                    ? 'Résultat de recherche noté — continue !'
                    : 'Touche pour noter ce résultat de recherche',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _noted ? AppColors.teal : AppColors.inkSoft,
                ),
              ),
            ),
            if (_noted)
              const Icon(
                Icons.verified_rounded,
                color: AppColors.teal,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline step question — MCQ shown on the immersive step card (dark bg).
// answerIndex == -1 → self-assessment: both choices get a positive checkmark.
// ---------------------------------------------------------------------------

class StepQuestionWidget extends StatefulWidget {
  final StepQuestion question;
  const StepQuestionWidget({super.key, required this.question});

  @override
  State<StepQuestionWidget> createState() => _StepQuestionWidgetState();
}

class _StepQuestionWidgetState extends State<StepQuestionWidget> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final answered = _selected != null;
    final selfAssessment = q.answerIndex == -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: 15,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(q.options.length, (i) {
          final isSelected = _selected == i;
          final isCorrect = q.answerIndex == i;
          Color bg;
          if (!answered) {
            bg = Colors.white.withValues(alpha: 0.11);
          } else if (isSelected) {
            if (selfAssessment) {
              bg = Colors.white.withValues(alpha: 0.28);
            } else if (isCorrect) {
              bg = AppColors.success.withValues(alpha: 0.50);
            } else {
              bg = AppColors.danger.withValues(alpha: 0.40);
            }
          } else {
            bg = Colors.white.withValues(alpha: 0.05);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GestureDetector(
              onTap: answered ? null : () => setState(() => _selected = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.70)
                        : Colors.white.withValues(alpha: 0.20),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        q.options[i],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (answered && isSelected)
                      Icon(
                        (!selfAssessment && !isCorrect)
                            ? Icons.cancel_rounded
                            : Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 17,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (answered) ...[
          const SizedBox(height: 4),
          Text(
            selfAssessment
                ? 'Bonne réflexion ! ✨'
                : _selected == q.answerIndex
                ? 'Exactement ! 🎯'
                : 'Pas tout à fait — pense-y en validant.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.80),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dark-theme interactions — used exclusively on step cards (dark gradient bg).
// Each type replaces the light-theme StepInteractive equivalent.
// ---------------------------------------------------------------------------

/// Dark-background dispatcher, replaces [StepInteractive] inside _StepCard.
class DarkStepInteractive extends StatelessWidget {
  final StepType type;
  const DarkStepInteractive({super.key, required this.type});

  @override
  Widget build(BuildContext context) => switch (type) {
    StepType.text => const _DarkConfidence(),
    StepType.fact => const _DarkReaction(),
    StepType.reflection => const _DarkEmojiReflection(),
    StepType.action => const SizedBox.shrink(), // timer widget handles it
    StepType.tip => const _DarkStarRating(),
    StepType.challenge => const _DarkTimeCommit(),
    StepType.framework => const _DarkSchemaInput(),
    StepType.research => const _DarkKeyWord(),
  };
}

// Shared 3-column tap-choice for dark backgrounds.
class _DarkTriChoice extends StatefulWidget {
  final String label;
  final List<(String, String)> opts;
  final List<String>? feedback;
  const _DarkTriChoice({required this.label, required this.opts, this.feedback});

  @override
  State<_DarkTriChoice> createState() => _DarkTriChoiceState();
}

class _DarkTriChoiceState extends State<_DarkTriChoice> {
  int? _sel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.68),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(widget.opts.length, (i) {
            final (emoji, text) = widget.opts[i];
            final sel = _sel == i;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i < widget.opts.length - 1 ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _sel = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: sel
                          ? Colors.white.withValues(alpha: 0.26)
                          : Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sel
                            ? Colors.white.withValues(alpha: 0.68)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight:
                                sel ? FontWeight.w700 : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (_sel != null && widget.feedback != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.feedback![_sel!],
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

// — Text: confidence self-rating —
class _DarkConfidence extends StatelessWidget {
  const _DarkConfidence();
  @override
  Widget build(BuildContext context) => _DarkTriChoice(
    label: 'Où tu en es ?',
    opts: const [
      ('❓', 'Pas clair'),
      ('🤔', 'Je vois'),
      ('✅', 'Compris !'),
    ],
    feedback: const [
      'Continue — ça va s\'éclaircir !',
      'Bonne piste, avance !',
      'Parfait — tu maîtrises ! 🎯',
    ],
  );
}

// — Fact: gut-reaction picker —
class _DarkReaction extends StatelessWidget {
  const _DarkReaction();
  @override
  Widget build(BuildContext context) => _DarkTriChoice(
    label: 'Ta réaction ?',
    opts: const [
      ('😐', 'Je savais'),
      ('😮', 'Intéressant !'),
      ('🤯', 'Mind blown !'),
    ],
  );
}

// — Reflection: emoji mood scale + optional text —
class _DarkEmojiReflection extends StatefulWidget {
  const _DarkEmojiReflection();

  @override
  State<_DarkEmojiReflection> createState() => _DarkEmojiReflectionState();
}

class _DarkEmojiReflectionState extends State<_DarkEmojiReflection> {
  int? _mood;
  static const _emojis = ['😶', '😐', '🤔', '💡', '🔥'];
  static const _labels = ['Flou', 'Basique', 'Je vois', 'Compris', 'Maîtrise'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ton niveau sur ce sujet ?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.68),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final sel = _mood == i;
            return GestureDetector(
              onTap: () => setState(() => _mood = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? Colors.white.withValues(alpha: 0.22)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(_emojis[i], style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 3),
                    Text(
                      _labels[i],
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: sel ? 1.0 : 0.42,
                        ),
                        fontSize: 9,
                        fontWeight:
                            sel ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        if (_mood != null) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
            child: TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Développe ta réflexion…',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ],
    );
  }
}

// — Tip: 1–5 star rating —
class _DarkStarRating extends StatefulWidget {
  const _DarkStarRating();

  @override
  State<_DarkStarRating> createState() => _DarkStarRatingState();
}

class _DarkStarRatingState extends State<_DarkStarRating> {
  int _stars = 0;
  static const _captions = [
    '😑 Pas vraiment',
    '🤷 Mouais',
    '👍 Assez utile',
    '💪 Très utile !',
    '🔥 Indispensable !',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Utile pour toi ?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.68),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            return GestureDetector(
              onTap: () => setState(() => _stars = i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Icon(
                  i < _stars
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: i < _stars
                      ? Colors.amber.shade300
                      : Colors.white.withValues(alpha: 0.32),
                  size: 36,
                ),
              ),
            );
          }),
        ),
        if (_stars > 0) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              _captions[_stars - 1],
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// — Challenge: time-commitment picker —
class _DarkTimeCommit extends StatefulWidget {
  const _DarkTimeCommit();

  @override
  State<_DarkTimeCommit> createState() => _DarkTimeCommitState();
}

class _DarkTimeCommitState extends State<_DarkTimeCommit> {
  int? _sel;
  static const _opts = ['⚡ Maintenant', '🌙 Ce soir', '📅 Demain'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quand tu le fais ?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.68),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_opts.length, (i) {
            final sel = _sel == i;
            return GestureDetector(
              onTap: () => setState(() => _sel = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? Colors.white.withValues(alpha: 0.26)
                      : Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel
                        ? Colors.white.withValues(alpha: 0.68)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _opts[i],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        sel ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }),
        ),
        if (_sel != null) ...[
          const SizedBox(height: 10),
          Text(
            'Engagement pris 🤝 — tiens-toi à la parole !',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

// — Framework: short schema text capture —
class _DarkSchemaInput extends StatefulWidget {
  const _DarkSchemaInput();

  @override
  State<_DarkSchemaInput> createState() => _DarkSchemaInputState();
}

class _DarkSchemaInputState extends State<_DarkSchemaInput> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schématise-le en quelques mots',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.68),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
            ),
          ),
          child: TextField(
            maxLines: 2,
            onChanged: (v) {
              if (v.length > 4 && !_saved) setState(() => _saved = true);
            },
            decoration: InputDecoration(
              hintText: 'Input → pratique → résultat…',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.38),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        if (_saved) ...[
          const SizedBox(height: 6),
          Text(
            'Schéma capturé ✓',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

// — Research: type one key word and "lock it in" —
class _DarkKeyWord extends StatefulWidget {
  const _DarkKeyWord();

  @override
  State<_DarkKeyWord> createState() => _DarkKeyWordState();
}

class _DarkKeyWordState extends State<_DarkKeyWord> {
  String? _word;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _ctrl.text.trim();
    if (v.isNotEmpty) setState(() => _word = v);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ton mot-clé de cette slide ?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.68),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        if (_word == null)
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Un seul mot…',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.38),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _submit,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        else
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.label_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _word!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() {
                    _word = null;
                    _ctrl.clear();
                  }),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.55),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise tile (used on the exercises page)
// ---------------------------------------------------------------------------

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  const ExerciseTile({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TintedIcon(
                icon: iconForStep(exercise.type),
                color: colorForStep(exercise.type),
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labelForStep(exercise.type).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colorForStep(exercise.type),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      exercise.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            exercise.instruction,
            style: TextStyle(color: AppColors.inkSoft, height: 1.4),
          ),
          const SizedBox(height: 14),
          StepInteractive(type: exercise.type),
        ],
      ),
    );
  }
}
