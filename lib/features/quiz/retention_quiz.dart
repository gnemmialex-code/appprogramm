import 'dart:math';

import '../../core/models/content_models.dart';

/// Builds a fresh **retention** questionnaire by pooling every question of the
/// program (chapter mini-quizzes, level quizzes and the final questionnaire),
/// de-duplicating, shuffling and picking [count] of them.
///
/// A new [rng] (or the default) yields a different selection each time — so the
/// periodic retention checks feel new and really test memory.
///
/// [focusModuleIds] biases the selection toward the chapters the user struggled
/// with: their questions are drawn first, then the rest fills the remaining
/// slots — so the adaptive checks insist on the weaker subjects.
List<QuizQuestion> buildRetentionQuiz(
  Program program, {
  int count = 8,
  Random? rng,
  Set<String> focusModuleIds = const {},
}) {
  final r = rng ?? Random();
  final pool = <String, QuizQuestion>{}; // keyed by question text → de-dupe
  final focusTexts = <String>{};

  void add(Iterable<QuizQuestion> qs, {bool focus = false}) {
    for (final q in qs) {
      pool[q.question] = q;
      if (focus) focusTexts.add(q.question);
    }
  }

  for (final m in program.modules) {
    add(m.quiz, focus: focusModuleIds.contains(m.id));
  }
  for (final p in program.parts) {
    add(p.quiz);
  }
  add(program.quiz);

  final focus = [
    for (final e in pool.entries)
      if (focusTexts.contains(e.key)) e.value
  ]..shuffle(r);
  final others = [
    for (final e in pool.entries)
      if (!focusTexts.contains(e.key)) e.value
  ]..shuffle(r);

  final ordered = [...focus, ...others];
  return ordered.take(count.clamp(1, ordered.length)).toList();
}
