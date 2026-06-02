import '../models/content_models.dart';
import '../../state/app_providers.dart';

/// Personalised-learning logic.
///
/// The app watches how the user behaves — time spent per chapter and mini-quiz
/// scores — to detect the subjects they struggle with, then reinforces those
/// subjects in the chapters that come afterwards.

/// A subject to revisit, derived from a chapter the user struggled with.
class ReinforcementTopic {
  final String moduleId;
  final String subject; // the chapter's subject (title without the "Ch. N —")
  final String recap; // a short reminder of what it was about
  final String reason; // why we resurface it (time / score)

  const ReinforcementTopic({
    required this.moduleId,
    required this.subject,
    required this.recap,
    required this.reason,
  });
}

/// Extracts the readable subject from a module title like
/// "Ch. 3 — Construire ton rituel" → "Construire ton rituel".
String subjectOf(String moduleTitle) {
  final i = moduleTitle.indexOf('—');
  return i >= 0 ? moduleTitle.substring(i + 1).trim() : moduleTitle.trim();
}

double _avg(Iterable<int> xs) {
  final l = xs.toList();
  if (l.isEmpty) return 0;
  return l.reduce((a, b) => a + b) / l.length;
}

/// True when the user appears to have struggled with [m]: either a weak
/// mini-quiz score (< 60 %) or clearly more time than average (≥ 15 s and
/// > 1.5× the average completed-chapter time).
bool moduleStruggled(Module m, ProgressState p, double avgTime) {
  final total = m.quiz.length;
  final score = p.moduleScores[m.id];
  final lowScore = score != null && total > 0 && score / total < 0.6;

  final t = p.moduleTimes[m.id] ?? 0;
  final slow = avgTime > 0 && t >= 15 && t > avgTime * 1.5;

  return lowScore || slow;
}

/// Ids of the completed chapters the user struggled with.
List<String> strugglingModuleIds(Program program, ProgressState p) {
  final times = [
    for (final m in program.modules)
      if (p.completedModules.contains(m.id)) p.moduleTimes[m.id] ?? 0,
  ].where((t) => t > 0);
  final avg = _avg(times);

  return [
    for (final m in program.modules)
      if (p.completedModules.contains(m.id) && moduleStruggled(m, p, avg)) m.id,
  ];
}

/// Reinforcement topics to surface inside the chapter at [moduleIndex]:
/// the subjects of EARLIER chapters the user struggled with, so later parts
/// "talk a bit more" about them.
List<ReinforcementTopic> reinforcementFor(
  Program program,
  ProgressState p,
  int moduleIndex,
) {
  final struggling = strugglingModuleIds(program, p).toSet();
  final topics = <ReinforcementTopic>[];
  for (var i = 0; i < program.modules.length && i < moduleIndex; i++) {
    final m = program.modules[i];
    if (!struggling.contains(m.id)) continue;

    final total = m.quiz.length;
    final score = p.moduleScores[m.id];
    final lowScore = score != null && total > 0 && score / total < 0.6;
    topics.add(ReinforcementTopic(
      moduleId: m.id,
      subject: subjectOf(m.title),
      recap: m.summary,
      reason: lowScore
          ? 'Quiz à consolider'
          : 'Tu y as pris ton temps',
    ));
  }
  return topics;
}

/// Targeted extra exercises generated from the reinforcement [topics] — the
/// later chapter doesn't just recap the weak subject, it makes the user
/// actively practise it again.
List<Exercise> reinforcementExercises(List<ReinforcementTopic> topics) => [
      for (final t in topics)
        Exercise(
          title: 'Renforcement : ${t.subject}',
          instruction:
              'Réexplique « ${t.subject} » avec tes propres mots, comme si tu '
              'l\'enseignais à un ami. Puis applique-le concrètement une fois '
              'aujourd\'hui.',
          type: StepType.reflection,
        ),
    ];
