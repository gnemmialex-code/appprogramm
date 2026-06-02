/// Domain models for a generated program.
///
/// These are plain, immutable value objects parsed from the JSON returned by
/// `generateContent`. Keeping them free of Flutter imports makes them trivial
/// to unit-test.
library;

enum StepType { text, audio, reflection, action }

StepType stepTypeFromString(String raw) {
  switch (raw) {
    case 'audio':
      return StepType.audio;
    case 'reflection':
      return StepType.reflection;
    case 'action':
      return StepType.action;
    default:
      return StepType.text;
  }
}

enum QuizType { mcq, trueFalse, swipe }

QuizType quizTypeFromString(String raw) {
  switch (raw) {
    case 'truefalse':
      return QuizType.trueFalse;
    case 'swipe':
      return QuizType.swipe;
    default:
      return QuizType.mcq;
  }
}

class ProgramStep {
  final String title;
  final String body;
  final StepType type;

  const ProgramStep({
    required this.title,
    required this.body,
    required this.type,
  });

  factory ProgramStep.fromJson(Map<String, dynamic> json) => ProgramStep(
        title: json['title'] as String,
        body: json['body'] as String,
        type: stepTypeFromString(json['type'] as String? ?? 'text'),
      );
}

class Exercise {
  final String title;
  final String instruction;
  final StepType type;

  const Exercise({
    required this.title,
    required this.instruction,
    required this.type,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        title: json['title'] as String,
        instruction: json['instruction'] as String,
        type: stepTypeFromString(json['type'] as String? ?? 'text'),
      );
}

class Module {
  final String id;
  final int level; // 1 (facile) .. 3 (avancé)
  final String title;
  final String summary;
  final String content;
  final List<ProgramStep> steps;
  final List<Exercise> exercises;
  final List<QuizQuestion> quiz;

  const Module({
    required this.id,
    this.level = 1,
    required this.title,
    required this.summary,
    required this.content,
    required this.steps,
    required this.exercises,
    this.quiz = const [],
  });

  factory Module.fromJson(Map<String, dynamic> json) => Module(
        id: json['id'] as String,
        level: json['level'] as int? ?? 1,
        title: json['title'] as String,
        summary: json['summary'] as String,
        content: json['content'] as String,
        steps: (json['steps'] as List<dynamic>)
            .map((e) => ProgramStep.fromJson(e as Map<String, dynamic>))
            .toList(),
        exercises: (json['exercises'] as List<dynamic>)
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        quiz: (json['quiz'] as List<dynamic>? ?? [])
            .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class QuizQuestion {
  final QuizType type;
  final String question;
  final List<String> options;
  final int answerIndex; // For MCQ.
  final bool answerBool; // For true/false & swipe.

  const QuizQuestion({
    required this.type,
    required this.question,
    this.options = const [],
    this.answerIndex = 0,
    this.answerBool = true,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        type: quizTypeFromString(json['type'] as String? ?? 'mcq'),
        question: json['question'] as String,
        options: (json['options'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        answerIndex: json['answerIndex'] as int? ?? 0,
        answerBool: json['answer'] as bool? ?? true,
      );
}

/// A "part": a group of 2–3 chapters sharing a theme, with its own
/// transversal quiz that reviews the whole group.
class ProgramPart {
  final String id;
  final int level; // 1..3 — learning level / intensity
  final String title;
  final String subtitle;
  final String intensity; // facile / intermédiaire / avancé
  final List<String> moduleIds;
  final List<QuizQuestion> quiz;

  const ProgramPart({
    required this.id,
    this.level = 1,
    required this.title,
    required this.subtitle,
    this.intensity = '',
    required this.moduleIds,
    required this.quiz,
  });

  factory ProgramPart.fromJson(Map<String, dynamic> json) => ProgramPart(
        id: json['id'] as String,
        level: json['level'] as int? ?? 1,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String? ?? '',
        intensity: json['intensity'] as String? ?? '',
        moduleIds: (json['moduleIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        quiz: (json['quiz'] as List<dynamic>? ?? [])
            .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Program {
  final String domain;
  final int level;
  final String title;
  final String subtitle;
  final List<Module> modules;
  final List<ProgramPart> parts;
  final List<QuizQuestion> quiz;
  final String finalSummary;

  const Program({
    required this.domain,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.modules,
    required this.parts,
    required this.quiz,
    required this.finalSummary,
  });

  factory Program.fromJson(Map<String, dynamic> json) => Program(
        domain: json['domain'] as String,
        level: json['level'] as int,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        modules: (json['modules'] as List<dynamic>)
            .map((e) => Module.fromJson(e as Map<String, dynamic>))
            .toList(),
        parts: (json['parts'] as List<dynamic>? ?? [])
            .map((e) => ProgramPart.fromJson(e as Map<String, dynamic>))
            .toList(),
        quiz: (json['quiz'] as List<dynamic>)
            .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
        finalSummary: json['finalSummary'] as String,
      );
}
