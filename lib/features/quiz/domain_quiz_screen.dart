import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/theme/app_colors.dart';
import '../domain_selection/domains_data.dart';
import 'domain_quiz_data.dart';

/// TikTok-style full-screen quiz for a given domain.
/// One question per card, swipe-up to advance (locked until answered).
class DomainQuizScreen extends StatefulWidget {
  final String domainId;
  const DomainQuizScreen({super.key, required this.domainId});

  @override
  State<DomainQuizScreen> createState() => _DomainQuizScreenState();
}

class _DomainQuizScreenState extends State<DomainQuizScreen> {
  late final List<DomainQuizQuestion> _questions;
  late final DomainItem _domain;
  final PageController _ctrl = PageController();
  final Map<int, int> _answers = {}; // questionIndex → choiceIndex
  int _page = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _questions = questionsFor(widget.domainId);
    _domain = kDomains.firstWhere(
      (d) => d.id == widget.domainId,
      orElse: () => kDomains.first,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _answer(int qIndex, int choiceIndex) {
    if (_answers.containsKey(qIndex)) return;
    final correct = _questions[qIndex].correctIndex == choiceIndex;
    setState(() {
      _answers[qIndex] = choiceIndex;
      if (correct) _score++;
    });
  }

  bool get _currentAnswered => _answers.containsKey(_page);

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Aucune question disponible',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final topPad = MediaQuery.of(context).padding.top;
    final total = _questions.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Question cards ──────────────────────────────────────────────
          PageView.builder(
            controller: _ctrl,
            scrollDirection: Axis.vertical,
            physics: _currentAnswered
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            onPageChanged: (p) => setState(() => _page = p),
            itemCount: total + 1,
            itemBuilder: (_, i) {
              if (i == total) {
                return _ResultCard(
                  score: _score,
                  total: total,
                  domain: _domain,
                );
              }
              return _QuizCard(
                question: _questions[i],
                domain: _domain,
                index: i,
                total: total,
                selectedAnswer: _answers[i],
                onAnswer: (c) => _answer(i, c),
              );
            },
          ),

          // ── Top bar: close + score ──────────────────────────────────────
          Positioned(
            top: topPad + 8,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _GlassButton(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$_score / $total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
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

// ─── Quiz card (one question) ─────────────────────────────────────────────────

class _QuizCard extends StatefulWidget {
  final DomainQuizQuestion question;
  final DomainItem domain;
  final int index;
  final int total;
  final int? selectedAnswer;
  final ValueChanged<int> onAnswer;

  const _QuizCard({
    required this.question,
    required this.domain,
    required this.index,
    required this.total,
    required this.selectedAnswer,
    required this.onAnswer,
  });

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(widget.domain.color);
    final base = hsl
        .withSaturation((hsl.saturation * 1.2).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 0.55).clamp(0.1, 0.4))
        .toColor();
    final darker = Color.lerp(base, Colors.black, 0.55)!;
    final light = hsl
        .withLightness((hsl.lightness + 0.25).clamp(0.4, 0.85))
        .toColor();

    final pad = MediaQuery.of(context).padding;
    final answered = widget.selectedAnswer != null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [base, darker],
        ),
      ),
      child: Stack(
        children: [
          // Animated orbs background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) => CustomPaint(
                painter: _QuizBgPainter(t: _bgCtrl.value, lightColor: light),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                pad.top + 56,
                24,
                pad.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < widget.total; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == widget.index ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i <= widget.index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Domain icon
                  Icon(
                    widget.domain.icon,
                    size: 44,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  const SizedBox(height: 18),

                  // Question
                  Text(
                    widget.question.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      shadows: [Shadow(blurRadius: 20, color: Colors.black38)],
                    ),
                  ),

                  const Spacer(),

                  // Choices
                  for (int i = 0; i < widget.question.choices.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ChoiceButton(
                        text: widget.question.choices[i],
                        state: widget.selectedAnswer == null
                            ? _ChoiceState.idle
                            : (i == widget.question.correctIndex
                                ? _ChoiceState.correct
                                : (widget.selectedAnswer == i
                                    ? _ChoiceState.wrong
                                    : _ChoiceState.dim)),
                        onTap: answered ? null : () => widget.onAnswer(i),
                      ),
                    ),

                  // Explanation
                  AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    child: answered
                        ? Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 8),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.question.explanation,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.88),
                                      fontSize: 14,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.keyboard_arrow_up_rounded,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.index + 1 < widget.total
                                          ? 'Suivant'
                                          : 'Voir les résultats',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
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

// ─── Choice button ────────────────────────────────────────────────────────────

enum _ChoiceState { idle, correct, wrong, dim }

class _ChoiceButton extends StatelessWidget {
  final String text;
  final _ChoiceState state;
  final VoidCallback? onTap;

  const _ChoiceButton({
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;
    Widget? trailing;

    switch (state) {
      case _ChoiceState.correct:
        bg = const Color(0xFF00C76A).withValues(alpha: 0.22);
        border = const Color(0xFF00C76A);
        textColor = Colors.white;
        trailing = const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF00C76A),
          size: 18,
        );
      case _ChoiceState.wrong:
        bg = AppColors.danger.withValues(alpha: 0.20);
        border = AppColors.danger;
        textColor = Colors.white;
        trailing = const Icon(
          Icons.cancel_rounded,
          color: AppColors.danger,
          size: 18,
        );
      case _ChoiceState.dim:
        bg = Colors.white.withValues(alpha: 0.05);
        border = Colors.white.withValues(alpha: 0.10);
        textColor = Colors.white.withValues(alpha: 0.35);
        trailing = null;
      case _ChoiceState.idle:
        bg = Colors.white.withValues(alpha: 0.12);
        border = Colors.white.withValues(alpha: 0.25);
        textColor = Colors.white;
        trailing = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 10),
              trailing,
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Result card ──────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final int score;
  final int total;
  final DomainItem domain;

  const _ResultCard({
    required this.score,
    required this.total,
    required this.domain,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? score / total : 0.0;
    final emoji = pct >= 0.8 ? '🏆' : (pct >= 0.5 ? '👏' : '📚');
    final message = pct >= 0.8
        ? 'Excellent !'
        : (pct >= 0.5 ? 'Bien joué !' : 'Continue à apprendre !');
    final sub = pct >= 0.8
        ? 'Tu maîtrises ce domaine.'
        : (pct >= 0.5
            ? 'Bon début, continue sur ta lancée.'
            : 'Reviens sur les cartes et réessaie.');

    final hsl = HSLColor.fromColor(domain.color);
    final base = hsl
        .withSaturation((hsl.saturation * 1.2).clamp(0, 1))
        .withLightness((hsl.lightness * 0.5).clamp(0.08, 0.35))
        .toColor();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [base, Color.lerp(base, Colors.black, 0.6)!],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              // Score pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '$score / $total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Retour',
                    style: TextStyle(
                      color: base,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
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

// ─── Animated background painter ─────────────────────────────────────────────

class _QuizBgPainter extends CustomPainter {
  final double t;
  final Color lightColor;

  _QuizBgPainter({required this.t, required this.lightColor});

  void _orb(Canvas c, Size s, double fx, double fy, double fr, double op,
      Color col) {
    final cx = fx * s.width;
    final cy = fy * s.height;
    final r = fr * s.shortestSide;
    c.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [col.withValues(alpha: op), col.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = math.pi * 2;
    _orb(canvas, size, 0.2 + 0.18 * math.sin(t * p), 0.15 + 0.1 * math.cos(t * p * 0.7), 0.45, 0.18, Colors.white);
    _orb(canvas, size, 0.75 + 0.14 * math.cos(t * p * 1.1 + 1), 0.28 + 0.2 * math.sin(t * p * 0.8), 0.38, 0.15, lightColor);
    _orb(canvas, size, 0.5 + 0.2 * math.sin(t * p * 0.9 + 2), 0.78 + 0.08 * math.cos(t * p * 1.2), 0.45, 0.14, Colors.white);
    _orb(canvas, size, 0.1 + 0.1 * math.cos(t * p * 0.6 + 3), 0.58 + 0.15 * math.sin(t * p * 0.75 + 1.5), 0.3, 0.16, lightColor);
  }

  @override
  bool shouldRepaint(_QuizBgPainter old) => old.t != t;
}

// ─── Glass button ─────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _GlassButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.20),
            width: 1,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}
