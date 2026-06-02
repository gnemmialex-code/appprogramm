import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumina/core/ai/generator.dart';
import 'package:lumina/core/models/content_models.dart';
import 'package:lumina/state/app_providers.dart';

void main() {
  group('generateContent', () {
    test('returns valid JSON parseable into a Program', () {
      final raw = generateContent('Sommeil', 1);
      final program = Program.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );

      expect(program.domain, 'Sommeil');
      expect(program.level, 1);
      expect(program.modules, isNotEmpty);
      expect(program.quiz, isNotEmpty);
      expect(program.finalSummary, isNotEmpty);
    });

    test('clamps the level to the 1..3 range', () {
      final low = Program.fromJson(
          jsonDecode(generateContent('Sport', 0)) as Map<String, dynamic>);
      final high = Program.fromJson(
          jsonDecode(generateContent('Sport', 9)) as Map<String, dynamic>);

      expect(low.level, 1);
      expect(high.level, 3);
    });

    test('produces several well-stocked chapters', () {
      final program = Program.fromJson(
          jsonDecode(generateContent('Nutrition', 2))
              as Map<String, dynamic>);

      expect(program.modules.length, greaterThanOrEqualTo(5));
      for (final m in program.modules) {
        expect(m.steps.length, greaterThanOrEqualTo(4),
            reason: 'module ${m.id} steps');
        expect(m.exercises, isNotEmpty, reason: 'module ${m.id} exercises');
        expect(m.quiz.length, 3, reason: 'module ${m.id} mini-quiz');
      }
    });

    test('every program ships 3 levels of rising intensity', () {
      final p = Program.fromJson(
          jsonDecode(generateContent('Sport', 1)) as Map<String, dynamic>);

      // 3 levels (parts) numbered 1 → 3.
      expect(p.parts.map((e) => e.level).toList(), [1, 2, 3]);

      // Modules are tagged with a level and spread across all three.
      expect(p.modules.map((m) => m.level).toSet(), {1, 2, 3});

      // Intensity rises: a level-3 chapter has more steps & exercises than a
      // level-1 chapter.
      final easy = p.modules.firstWhere((m) => m.level == 1);
      final hard = p.modules.firstWhere((m) => m.level == 3);
      expect(hard.steps.length, greaterThan(easy.steps.length));
      expect(hard.exercises.length, greaterThan(easy.exercises.length));
    });

    test('groups chapters into parts with a transversal quiz', () {
      final program = Program.fromJson(
          jsonDecode(generateContent('Confiance', 1)) as Map<String, dynamic>);

      expect(program.parts, isNotEmpty);
      final ids = program.modules.map((m) => m.id).toSet();
      for (final part in program.parts) {
        expect(part.moduleIds.length, greaterThanOrEqualTo(2));
        expect(part.quiz, isNotEmpty, reason: 'part ${part.id} quiz');
        for (final id in part.moduleIds) {
          expect(ids, contains(id), reason: 'part ${part.id} references $id');
        }
      }
      // Every chapter belongs to exactly one part.
      final assigned =
          program.parts.expand((p) => p.moduleIds).toList();
      expect(assigned.toSet().length, assigned.length, reason: 'no overlap');
      expect(assigned.toSet(), ids, reason: 'all chapters covered');
    });

    test('custom theme + objective build a complete, woven program', () {
      const objectif = 'tenir un discours de 5 minutes sans notes';
      final program = Program.fromJson(
          jsonDecode(generateContent('Prise de parole', 2,
              objectif: objectif)) as Map<String, dynamic>);

      // Unknown/custom theme still yields a full program.
      expect(program.modules.length, greaterThanOrEqualTo(5));
      expect(program.parts, isNotEmpty);
      // The objective is woven into the generated content.
      expect(program.subtitle, isNotEmpty);
      expect(program.finalSummary, contains(objectif));
    });

    test('quiz contains the three supported question types', () {
      final program = Program.fromJson(
          jsonDecode(generateContent('Anxiété', 1)) as Map<String, dynamic>);
      final types = program.quiz.map((q) => q.type).toSet();

      expect(types, contains(QuizType.mcq));
      expect(types, contains(QuizType.trueFalse));
      expect(types, contains(QuizType.swipe));
    });
  });

  group('ProgressState', () {
    test('round-trips through a map', () {
      const state = ProgressState(
        completedModules: {'m1', 'm2'},
        quizScore: 4,
        quizTotal: 6,
        moduleScores: {'m1': 3, 'm2': 2},
        partScores: {'p1': 4},
        badges: {'Premier pas'},
      );
      final restored = ProgressState.fromMap(state.toMap());

      expect(restored.completedModules, state.completedModules);
      expect(restored.quizScore, 4);
      expect(restored.quizTotal, 6);
      expect(restored.moduleScores['m1'], 3);
      expect(restored.partScores['p1'], 4);
      expect(restored.badges, contains('Premier pas'));
    });
  });

  group('ReminderState', () {
    test('round-trips the automatic-reminder time', () {
      const state = ReminderState(
        enabled: true,
        hour: 8,
        minute: 30,
        autoHour: 21,
        autoMinute: 15,
      );
      final restored = ReminderState.fromMap(state.toMap());

      expect(restored.autoHour, 21);
      expect(restored.autoMinute, 15);
      expect(restored.hour, 8);
      expect(restored.enabled, isTrue);
    });
  });
}
