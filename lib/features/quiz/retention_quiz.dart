import 'dart:math';

import '../../core/models/content_models.dart';

/// How far along the learner is, on a 0..1 scale, combining completed chapters
/// and the number of retention checks already taken. Drives how hard the next
/// retention quiz gets.
double retentionStage(Program program, int completedModules, int checksDone) {
  final total = program.modules.length;
  final prog = total == 0 ? 0.0 : completedModules / total;
  return (prog * 0.85 + checksDone * 0.07).clamp(0.0, 1.0);
}

/// Short label for the current difficulty tier, shown to the user.
String retentionLevelLabel(double stage) => stage < 0.34
    ? 'Échauffement'
    : stage < 0.67
    ? 'Intermédiaire'
    : 'Pointu';

/// One-line explanation of what the current tier emphasises.
String retentionLevelBlurb(double stage) => stage < 0.34
    ? 'Les essentiels de tes premiers chapitres.'
    : stage < 0.67
    ? 'On revient sur le début et on creuse les détails.'
    : 'Questions pointues et pièges sur tout ton parcours — surtout les débuts.';

class _PoolItem {
  final QuizQuestion q;
  final int chapter; // -1 if unknown
  final int difficulty; // 1..3
  bool focus;
  _PoolItem(this.q, this.chapter, this.difficulty, this.focus);
}

/// Builds a **progressive** retention questionnaire.
///
/// The further the learner has gone ([completedModules] + [checksDone]):
///  • the more questions it asks (6 → 12),
///  • the harder they get — it mixes in difficulty-2 then difficulty-3
///    "detail" questions and shuffles MCQ option order so position memory
///    doesn't help,
///  • the more it favours the **earliest chapters**, testing long-term recall
///    of how things began.
///
/// [focusModuleIds] still biases toward chapters the user struggled with, and
/// the result is ordered easy → hard so each session ramps up.
List<QuizQuestion> buildRetentionQuiz(
  Program program, {
  required int completedModules,
  int checksDone = 0,
  Random? rng,
  Set<String> focusModuleIds = const {},
}) {
  final r = rng ?? Random();
  final stage = retentionStage(program, completedModules, checksDone);
  final totalChapters = program.modules.length.clamp(1, 999);

  // ── Pool every question once, with chapter + difficulty metadata ──────────
  final pool = <String, _PoolItem>{};
  void add(Iterable<QuizQuestion> qs, {bool focus = false}) {
    for (final q in qs) {
      final existing = pool[q.question];
      if (existing != null) {
        existing.focus = existing.focus || focus;
        continue;
      }
      pool[q.question] = _PoolItem(q, q.chapter, q.difficulty, focus);
    }
  }

  for (var i = 0; i < program.modules.length; i++) {
    final m = program.modules[i];
    add(m.quiz, focus: focusModuleIds.contains(m.id));
  }
  for (final p in program.parts) {
    add(p.quiz);
  }
  add(program.quiz);
  add(program.detailQuiz);

  if (pool.isEmpty) return const [];

  // ── How many, and the difficulty mix ─────────────────────────────────────
  final count = (6 + (stage * 6).round()).clamp(6, 12);
  final List<double> w = stage < 0.34
      ? const [0.8, 0.2, 0.0]
      : stage < 0.67
      ? const [0.45, 0.4, 0.15]
      : const [0.25, 0.4, 0.35];
  var q2 = (count * w[1]).round();
  var q3 = (count * w[2]).round();
  var q1 = count - q2 - q3;
  if (q1 < 0) q1 = 0;

  final buckets = <int, List<_PoolItem>>{1: [], 2: [], 3: []};
  for (final it in pool.values) {
    buckets[it.difficulty.clamp(1, 3)]!.add(it);
  }

  // Early-material bias: at high [stage], sort earliest chapters first; at low
  // stage it's mostly random. Focus chapters always come first.
  double earlyKey(_PoolItem it) {
    final ch = (it.chapter < 0 ? totalChapters / 2 : it.chapter).toDouble();
    final focusBonus = it.focus ? -1000.0 : 0.0;
    return focusBonus +
        ch * (0.4 + 0.6 * stage) +
        r.nextDouble() * totalChapters * (1 - stage);
  }

  for (final b in buckets.values) {
    b.sort((a, c) => earlyKey(a).compareTo(earlyKey(c)));
  }

  final taken = <_PoolItem>[];
  final usedTexts = <String>{};
  void takeFrom(int diff, int n) {
    for (final it in buckets[diff]!) {
      if (taken.length >= count || n <= 0) break;
      if (usedTexts.add(it.q.question)) {
        taken.add(it);
        n--;
      }
    }
  }

  takeFrom(3, q3);
  takeFrom(2, q2);
  takeFrom(1, q1);

  // Fill any shortfall (e.g. a difficulty had too few) from whatever remains,
  // preferring the earliest material.
  if (taken.length < count) {
    final remaining = [
      for (final it in pool.values)
        if (!usedTexts.contains(it.q.question)) it,
    ]..sort((a, c) => earlyKey(a).compareTo(earlyKey(c)));
    for (final it in remaining) {
      if (taken.length >= count) break;
      if (usedTexts.add(it.q.question)) taken.add(it);
    }
  }

  // Focus (struggled) chapters lead; otherwise ramp the session easy → hard.
  taken.sort((a, c) {
    if (a.focus != c.focus) return a.focus ? -1 : 1;
    return a.difficulty.compareTo(c.difficulty);
  });

  // Beyond the warm-up, scramble MCQ option order so memorising "it was the 2nd
  // one" no longer works — a real difficulty bump on familiar questions.
  final scramble = stage >= 0.34;
  return [
    for (final it in taken)
      (scramble && it.q.type == QuizType.mcq && it.q.options.length > 1)
          ? _shuffleOptions(it.q, r)
          : it.q,
  ];
}

QuizQuestion _shuffleOptions(QuizQuestion q, Random r) {
  final order = List<int>.generate(q.options.length, (i) => i)..shuffle(r);
  return q.copyWith(
    options: [for (final i in order) q.options[i]],
    answerIndex: order.indexOf(q.answerIndex),
  );
}
