import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_providers.dart';
import '../domain_selection/domains_data.dart';
import 'domain_quiz_data.dart';

// ─── Entry point ──────────────────────────────────────────────────────────────

class DomainQuizScreen extends ConsumerStatefulWidget {
  final String domainId;
  const DomainQuizScreen({super.key, required this.domainId});

  @override
  ConsumerState<DomainQuizScreen> createState() => _DomainQuizScreenState();
}

class _DomainQuizScreenState extends ConsumerState<DomainQuizScreen> {
  final _rng = math.Random();

  late int _level;
  late List<DomainQuizQuestion> _pool;
  int _correct = 0;
  int _totalQ = 0;
  DomainQuizQuestion? _current;
  int? _chosen;
  bool _answered = false;
  bool _finished = false;

  DomainItem get _domain => kDomains.firstWhere(
        (d) => d.id == widget.domainId,
        orElse: () => kDomains.first,
      );

  @override
  void initState() {
    super.initState();
    final progress = ref.read(quizProgressProvider.notifier);
    _level = progress.currentLevel(widget.domainId);
    _loadLevel(_level);
  }

  void _loadLevel(int level) {
    final questions = questionsForLevel(widget.domainId, level);
    final pool = questions.isNotEmpty
        ? (List<DomainQuizQuestion>.from(questions)..shuffle(_rng))
        : (List<DomainQuizQuestion>.from(questionsFor(widget.domainId))
          ..shuffle(_rng));
    setState(() {
      _level = level;
      _pool = pool;
      _totalQ = pool.length;
      _correct = 0;
      _current = pool.isNotEmpty ? pool[0] : null;
      _chosen = null;
      _answered = false;
      _finished = pool.isEmpty;
    });
  }

  void _answer(int index) {
    if (_answered) return;
    setState(() {
      _chosen = index;
      _answered = true;
    });
  }

  void _next() {
    if (!_answered) return;
    final ok = _chosen == _current!.correctIndex;
    setState(() {
      if (ok) {
        _correct++;
        _pool.removeAt(0);
      } else {
        final failed = _pool.removeAt(0);
        if (_pool.isEmpty) {
          _pool.add(failed);
        } else {
          final pos = 1 + _rng.nextInt(_pool.length);
          _pool.insert(pos, failed);
        }
      }
      if (_pool.isEmpty) {
        _finished = true;
        _current = null;
        ref
            .read(quizProgressProvider.notifier)
            .completeLevel(widget.domainId, _level);
      } else {
        _current = _pool[0];
        _chosen = null;
        _answered = false;
      }
    });
  }

  void _nextLevel() {
    if (_level >= 10) {
      context.pop();
    } else {
      _loadLevel(_level + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _ResultScreen(
        domain: _domain,
        correct: _correct,
        total: _totalQ,
        level: _level,
        hasNextLevel: _level < 10,
        onNext: _nextLevel,
        onClose: () => context.pop(),
      );
    }
    if (_current == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    return _QuizScreen(
      domain: _domain,
      question: _current!,
      chosen: _chosen,
      answered: _answered,
      correct: _correct,
      total: _totalQ,
      level: _level,
      onAnswer: _answer,
      onNext: _next,
      onClose: () => context.pop(),
    );
  }
}

// ─── Feed-style animated background ──────────────────────────────────────────

class _FeedBg extends StatefulWidget {
  final Color domainColor;
  const _FeedBg({required this.domainColor});

  @override
  State<_FeedBg> createState() => _FeedBgState();
}

class _FeedBgState extends State<_FeedBg> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(widget.domainColor);
    final vivid = hsl
        .withSaturation((hsl.saturation * 1.35).clamp(0.0, 1.0))
        .withLightness((hsl.lightness + 0.07).clamp(0.28, 0.65))
        .toColor();
    final dark = Color.lerp(vivid, Colors.black, 0.40)!;
    final light = hsl
        .withLightness((hsl.lightness + 0.32).clamp(0.45, 0.92))
        .toColor();

    return Stack(
      children: [
        // Gradient base
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [vivid, dark],
              ),
            ),
          ),
        ),
        // Animated orbs
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) => CustomPaint(
              painter: _OrbsPainter(
                t: _ctrl.value,
                lightColor: light,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrbsPainter extends CustomPainter {
  final double t;
  final Color lightColor;
  const _OrbsPainter({required this.t, required this.lightColor});

  void _orb(Canvas c, Size s, double fx, double fy, double fr, double opacity,
      Color col) {
    final cx = fx * s.width;
    final cy = fy * s.height;
    final r = fr * s.shortestSide;
    c.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [col.withValues(alpha: opacity), col.withValues(alpha: 0.0)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = math.pi * 2;
    _orb(canvas, size, 0.22 + 0.20 * math.sin(t * p),
        0.18 + 0.13 * math.cos(t * p * 0.7), 0.55, 0.28, Colors.white);
    _orb(canvas, size, 0.80 + 0.16 * math.cos(t * p * 1.1 + 1.0),
        0.32 + 0.22 * math.sin(t * p * 0.8 + 0.5), 0.48, 0.25, lightColor);
    _orb(canvas, size, 0.50 + 0.24 * math.sin(t * p * 0.85 + 2.0),
        0.78 + 0.10 * math.cos(t * p * 1.2), 0.55, 0.20, Colors.white);
    _orb(canvas, size, 0.60 + 0.30 * math.cos(t * p * 1.5 + 1.2),
        0.50 + 0.32 * math.sin(t * p * 1.3 + 0.8), 0.32, 0.22, lightColor);
  }

  @override
  bool shouldRepaint(_OrbsPainter old) => old.t != t;
}

// ─── Quiz screen ──────────────────────────────────────────────────────────────

class _QuizScreen extends StatelessWidget {
  final DomainItem domain;
  final DomainQuizQuestion question;
  final int? chosen;
  final bool answered;
  final int correct;
  final int total;
  final int level;
  final ValueChanged<int> onAnswer;
  final VoidCallback onNext;
  final VoidCallback onClose;

  const _QuizScreen({
    required this.domain,
    required this.question,
    required this.chosen,
    required this.answered,
    required this.correct,
    required this.total,
    required this.level,
    required this.onAnswer,
    required this.onNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Feed-style animated background
          Positioned.fill(child: _FeedBg(domainColor: domain.color)),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(domain.icon,
                                color: Colors.white70, size: 13),
                            const SizedBox(width: 6),
                            Text(
                              'Niv. $level · $correct/$total',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total > 0 ? correct / total : 0,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.20),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),

                const Spacer(),

                // Question card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      question.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        shadows: [Shadow(blurRadius: 12, color: Colors.black26)],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Choices
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (int i = 0; i < question.choices.length; i++)
                        _Choice(
                          text: question.choices[i],
                          index: i,
                          chosen: chosen,
                          correctIndex: question.correctIndex,
                          answered: answered,
                          onTap: () => onAnswer(i),
                        ),
                    ],
                  ),
                ),

                // Explanation + Next
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  child: answered
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.30),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chosen == question.correctIndex
                                          ? '✓'
                                          : '↺',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            chosen == question.correctIndex
                                                ? const Color(0xFF6EFFC0)
                                                : const Color(0xFFFF8080),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        chosen == question.correctIndex
                                            ? question.explanation
                                            : '${question.explanation}\n↺ Question à repasser.',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: onNext,
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.20),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.35),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Suivant →',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                SizedBox(height: bottomPad + 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Choice button ────────────────────────────────────────────────────────────

class _Choice extends StatelessWidget {
  final String text;
  final int index;
  final int? chosen;
  final int correctIndex;
  final bool answered;
  final VoidCallback onTap;

  const _Choice({
    required this.text,
    required this.index,
    required this.chosen,
    required this.correctIndex,
    required this.answered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white.withValues(alpha: 0.10);
    Color border = Colors.white.withValues(alpha: 0.22);
    Color textColor = Colors.white;

    if (answered) {
      if (index == correctIndex) {
        bg = const Color(0xFF6EFFC0).withValues(alpha: 0.18);
        border = const Color(0xFF6EFFC0).withValues(alpha: 0.55);
        textColor = const Color(0xFF6EFFC0);
      } else if (index == chosen) {
        bg = const Color(0xFFFF8080).withValues(alpha: 0.18);
        border = const Color(0xFFFF8080).withValues(alpha: 0.55);
        textColor = const Color(0xFFFF8080);
      } else {
        textColor = Colors.white38;
        border = Colors.white.withValues(alpha: 0.08);
      }
    }

    return GestureDetector(
      onTap: answered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Result screen ────────────────────────────────────────────────────────────

class _ResultScreen extends StatelessWidget {
  final DomainItem domain;
  final int correct;
  final int total;
  final int level;
  final bool hasNextLevel;
  final VoidCallback onNext;
  final VoidCallback onClose;

  const _ResultScreen({
    required this.domain,
    required this.correct,
    required this.total,
    required this.level,
    required this.hasNextLevel,
    required this.onNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? correct / total : 0.0;
    final stars = pct == 1.0
        ? 5
        : pct >= 0.8
            ? 4
            : pct >= 0.6
                ? 3
                : 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _FeedBg(domainColor: domain.color)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.30),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(domain.icon, color: Colors.white, size: 36),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    hasNextLevel
                        ? 'Niveau $level terminé !'
                        : 'Domaine maîtrisé ! 🏆',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(blurRadius: 16, color: Colors.black38)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '⭐' * stars,
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$correct / $total questions réussies',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 16),
                  ),
                  if (hasNextLevel) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        '✦ Niveau suivant débloqué',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  if (hasNextLevel)
                    GestureDetector(
                      onTap: onNext,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.40),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Niveau suivant →',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Fermer',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
