import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumina/core/adaptive/adaptive.dart';
import 'package:lumina/core/ai/generator.dart';
import 'package:lumina/core/models/content_models.dart';
import 'package:lumina/features/quiz/retention_quiz.dart';
import 'package:lumina/state/app_providers.dart';

void main() {
  Program program() => Program.fromJson(
      jsonDecode(generateContent('Productivité', 1)) as Map<String, dynamic>);

  group('struggle detection', () {
    test('flags a chapter with a weak mini-quiz score', () {
      final p = program();
      final m1 = p.modules.first;
      final progress = ProgressState(
        completedModules: {m1.id},
        moduleScores: {m1.id: 0}, // 0/3 → struggled
      );

      expect(strugglingModuleIds(p, progress), contains(m1.id));
    });

    test('flags a chapter where the user spent much more time', () {
      final p = program();
      final ids = p.modules.map((m) => m.id).toList();
      final progress = ProgressState(
        completedModules: {ids[0], ids[1], ids[2]},
        moduleTimes: {ids[0]: 10, ids[1]: 10, ids[2]: 100}, // avg 40, 100 > 60
      );

      final struggling = strugglingModuleIds(p, progress);
      expect(struggling, contains(ids[2]));
      expect(struggling, isNot(contains(ids[0])));
    });
  });

  group('reinforcement', () {
    test('surfaces earlier struggled subjects in a later chapter', () {
      final p = program();
      final m1 = p.modules.first;
      final progress = ProgressState(
        completedModules: {m1.id},
        moduleScores: {m1.id: 0},
      );

      // For a later chapter (index 3), m1's subject should be reinforced.
      final topics = reinforcementFor(p, progress, 3);
      expect(topics.map((t) => t.moduleId), contains(m1.id));
      expect(topics.first.subject, isNotEmpty);

      // But not for chapter 0 (nothing comes before it).
      expect(reinforcementFor(p, progress, 0), isEmpty);
    });

    test('generates a targeted extra exercise per weak subject', () {
      final p = program();
      final m1 = p.modules.first;
      final progress = ProgressState(
        completedModules: {m1.id},
        moduleScores: {m1.id: 0},
      );

      final topics = reinforcementFor(p, progress, 3);
      final extra = reinforcementExercises(topics);

      expect(extra.length, topics.length);
      expect(extra.first.instruction, contains(topics.first.subject));
    });
  });

  group('adaptive retention quiz', () {
    test('prioritises the struggled chapter\'s questions first', () {
      final p = program();
      final m1 = p.modules.first;
      final focusTexts = m1.quiz.map((q) => q.question).toSet();

      final quiz = buildRetentionQuiz(
        p,
        count: 8,
        rng: Random(7),
        focusModuleIds: {m1.id},
      );

      // The leading questions come from the focused chapter.
      expect(focusTexts.contains(quiz.first.question), isTrue);
      final leading = quiz.take(focusTexts.length);
      expect(leading.every((q) => focusTexts.contains(q.question)), isTrue);
    });
  });
}
