import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumina/core/ai/generator.dart';
import 'package:lumina/core/models/content_models.dart';
import 'package:lumina/features/quiz/retention_quiz.dart';
import 'package:lumina/state/app_providers.dart';

void main() {
  Program program() => Program.fromJson(
      jsonDecode(generateContent('Sommeil', 1)) as Map<String, dynamic>);

  group('buildRetentionQuiz', () {
    test('returns the requested number of questions from the program', () {
      final p = program();
      final quiz = buildRetentionQuiz(p, count: 8, rng: Random(42));

      expect(quiz.length, 8);

      // Every question must come from the program's combined pool.
      final pool = <String>{
        for (final m in p.modules) ...m.quiz.map((q) => q.question),
        for (final part in p.parts) ...part.quiz.map((q) => q.question),
        ...p.quiz.map((q) => q.question),
      };
      for (final q in quiz) {
        expect(pool, contains(q.question));
      }
    });

    test('different seeds produce different selections', () {
      final p = program();
      final a = buildRetentionQuiz(p, count: 6, rng: Random(1))
          .map((q) => q.question)
          .toList();
      final b = buildRetentionQuiz(p, count: 6, rng: Random(2))
          .map((q) => q.question)
          .toList();
      expect(a, isNot(equals(b)));
    });

    test('final questionnaire is comprehensive', () {
      // One MCQ per chapter + spreads → clearly more than a mini-quiz.
      expect(program().quiz.length, greaterThanOrEqualTo(10));
    });
  });

  group('RetentionState', () {
    test('round-trips through a map', () {
      const s = RetentionState(
        nextDueMillis: 123,
        lastScore: 5,
        lastTotal: 8,
        checks: 2,
        announcedDueMillis: 123,
      );
      final r = RetentionState.fromMap(s.toMap());
      expect(r.nextDueMillis, 123);
      expect(r.lastScore, 5);
      expect(r.checks, 2);
    });

    test('isDue / shouldAnnounce reflect the due time', () {
      final past = DateTime.now()
          .subtract(const Duration(minutes: 1))
          .millisecondsSinceEpoch;
      final future = DateTime.now()
          .add(const Duration(hours: 1))
          .millisecondsSinceEpoch;

      expect(RetentionState(nextDueMillis: past).isDue, isTrue);
      expect(RetentionState(nextDueMillis: future).isDue, isFalse);

      // Already announced for this due event → should not re-announce.
      expect(
        RetentionState(nextDueMillis: past, announcedDueMillis: past)
            .shouldAnnounce,
        isFalse,
      );
      expect(RetentionState(nextDueMillis: past).shouldAnnounce, isTrue);
    });
  });
}
