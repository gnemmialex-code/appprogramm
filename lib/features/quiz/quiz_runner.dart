import 'package:flutter/material.dart';

import '../../core/models/content_models.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';

/// A self-contained, reusable quiz flow used by both the standalone quiz
/// screen and each chapter's mini-quiz. Renders a progress bar, one question
/// at a time (MCQ / true-false / Tinder-style swipe) with a live score, and
/// calls [onFinished] with the final score once the last question is answered.
///
/// Expects a bounded height (place inside an [Expanded] or sized box).
class QuizRunner extends StatefulWidget {
  final List<QuizQuestion> questions;
  final void Function(int score, int total) onFinished;
  final String finishLabel;

  const QuizRunner({
    super.key,
    required this.questions,
    required this.onFinished,
    this.finishLabel = 'Voir mon score',
  });

  @override
  State<QuizRunner> createState() => _QuizRunnerState();
}

class _QuizRunnerState extends State<QuizRunner> {
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;

  void _answer(bool correct, {int? selectedIndex}) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selected = selectedIndex;
      if (correct) _score++;
    });
  }

  void _next() {
    if (_index >= widget.questions.length - 1) {
      widget.onFinished(_score, widget.questions.length);
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.questions;
    final q = quiz[_index];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GradientProgressBar(
                value: (_index + 1) / quiz.length,
                height: 8,
              ),
            ),
            const SizedBox(width: 12),
            BadgeChip(
              label: 'Score $_score',
              icon: Icons.star_rounded,
              color: AppColors.sun,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text('${_index + 1} / ${quiz.length}',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 12)),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: switch (q.type) {
            QuizType.mcq => _McqView(
                question: q,
                answered: _answered,
                selected: _selected,
                onSelect: (i) => _answer(i == q.answerIndex, selectedIndex: i),
              ),
            QuizType.trueFalse => _TrueFalseView(
                question: q,
                answered: _answered,
                selected: _selected,
                onSelect: (val) =>
                    _answer(val == q.answerBool, selectedIndex: val ? 1 : 0),
              ),
            QuizType.swipe => _SwipeView(
                key: ValueKey(_index),
                question: q,
                onSwiped: (val) => _answer(val == q.answerBool),
              ),
          },
        ),
        const SizedBox(height: 12),
        GradientButton(
          label: _index >= quiz.length - 1 ? widget.finishLabel : 'Suivant',
          onPressed: _answered ? _next : null,
        ),
      ],
    );
  }
}

class _McqView extends StatelessWidget {
  final QuizQuestion question;
  final bool answered;
  final int? selected;
  final ValueChanged<int> onSelect;

  const _McqView({
    required this.question,
    required this.answered,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(question.question,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        ...List.generate(question.options.length, (i) {
          final isCorrect = i == question.answerIndex;
          final isPicked = i == selected;
          Color bg = AppColors.surface;
          if (answered && isCorrect) {
            bg = AppColors.success.withValues(alpha: 0.18);
          } else if (answered && isPicked && !isCorrect) {
            bg = AppColors.danger.withValues(alpha: 0.16);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SoftCard(
              color: bg,
              onTap: answered ? null : () => onSelect(i),
              child: Row(
                children: [
                  Expanded(
                    child: Text(question.options[i],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  if (answered && isCorrect)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success),
                  if (answered && isPicked && !isCorrect)
                    const Icon(Icons.cancel_rounded, color: AppColors.danger),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TrueFalseView extends StatelessWidget {
  final QuizQuestion question;
  final bool answered;
  final int? selected;
  final ValueChanged<bool> onSelect;

  const _TrueFalseView({
    required this.question,
    required this.answered,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    Widget tile(String label, bool value, Color color, IconData icon) {
      final picked = selected == (value ? 1 : 0);
      final isCorrect = value == question.answerBool;
      Color bg = color.withValues(alpha: 0.16);
      if (answered && isCorrect) {
        bg = AppColors.success.withValues(alpha: 0.20);
      } else if (answered && picked && !isCorrect) {
        bg = AppColors.danger.withValues(alpha: 0.16);
      }
      return Expanded(
        child: SoftCard(
          color: bg,
          onTap: answered ? null : () => onSelect(value),
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              Icon(icon, size: 40, color: AppColors.ink),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question.question,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 28),
        Row(
          children: [
            tile('Vrai', true, AppColors.mint, Icons.thumb_up_rounded),
            const SizedBox(width: 14),
            tile('Faux', false, AppColors.rose, Icons.thumb_down_rounded),
          ],
        ),
      ],
    );
  }
}

/// Tinder-style swipe card: drag right = vrai, left = faux.
class _SwipeView extends StatefulWidget {
  final QuizQuestion question;
  final ValueChanged<bool> onSwiped;
  const _SwipeView({super.key, required this.question, required this.onSwiped});

  @override
  State<_SwipeView> createState() => _SwipeViewState();
}

class _SwipeViewState extends State<_SwipeView> {
  Offset _drag = Offset.zero;
  bool _gone = false;

  void _commit(bool right) {
    setState(() => _gone = true);
    widget.onSwiped(right);
  }

  @override
  Widget build(BuildContext context) {
    if (_gone) {
      return Center(
        child: Icon(Icons.check_circle_outline_rounded,
            size: 64, color: AppColors.success),
      );
    }
    final angle = _drag.dx / 1200;
    return Column(
      children: [
        Text('Glisse la carte', style: TextStyle(color: AppColors.inkSoft)),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: GestureDetector(
              onPanUpdate: (dt) => setState(() => _drag += dt.delta),
              onPanEnd: (_) {
                if (_drag.dx > 110) {
                  _commit(true);
                } else if (_drag.dx < -110) {
                  _commit(false);
                } else {
                  setState(() => _drag = Offset.zero);
                }
              },
              child: Transform.translate(
                offset: _drag,
                child: Transform.rotate(angle: angle, child: _card()),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _hint('Faux', Icons.arrow_back_rounded, AppColors.rose),
            _hint('Vrai', Icons.arrow_forward_rounded, AppColors.mint),
          ],
        ),
      ],
    );
  }

  Widget _hint(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _card() {
    final tint = _drag.dx > 30
        ? AppColors.mint
        : _drag.dx < -30
            ? AppColors.rose
            : AppColors.lavender;
    return Container(
      width: 280,
      height: 320,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.softShadow,
        border: Border.all(color: tint, width: 2),
      ),
      child: Center(
        child: Text(
          widget.question.question,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
