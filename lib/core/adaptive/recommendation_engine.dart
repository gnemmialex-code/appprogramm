import '../models/content_models.dart';
import '../../features/domain_selection/domains_data.dart';
import '../../state/app_providers.dart';
import 'adaptive.dart';

/// A single suggested next step after (almost) finishing a theme.
class Recommendation {
  final String domainId;
  final String domainLabel;
  final String subThemeId;
  final String subThemeLabel;
  final String emoji;
  final String reason; // why we suggest it (ties to what was learned/struggled)
  final bool isSameDomain; // deepen current vs explore adjacent
  final bool isExpert; // suggest the Expert mode of this sub-theme

  const Recommendation({
    required this.domainId,
    required this.domainLabel,
    required this.subThemeId,
    required this.subThemeLabel,
    required this.emoji,
    required this.reason,
    this.isSameDomain = true,
    this.isExpert = false,
  });
}

/// A compact "mini report" describing the finished journey, used to head the
/// recommendation section.
class CompletionReport {
  final String domain;
  final int modulesDone;
  final int modulesTotal;
  final double completionRatio;
  final double avgQuizRatio; // 0..1 across recorded module quizzes
  final List<String>
  strugglingSubjects; // subjects that took longest / weak quiz
  final List<String> strongSubjects; // mastered subjects
  final int totalMinutes; // total time spent (approx)
  final List<Recommendation> recommendations;

  const CompletionReport({
    required this.domain,
    required this.modulesDone,
    required this.modulesTotal,
    required this.completionRatio,
    required this.avgQuizRatio,
    required this.strugglingSubjects,
    required this.strongSubjects,
    required this.totalMinutes,
    required this.recommendations,
  });

  bool get isAlmostComplete => completionRatio >= 0.8;

  String get masteryLabel {
    if (avgQuizRatio >= 0.85) return 'Excellente maîtrise';
    if (avgQuizRatio >= 0.65) return 'Bonne maîtrise';
    if (avgQuizRatio >= 0.4) return 'Maîtrise en cours';
    return 'Bases posées';
  }

  String get headline {
    if (strugglingSubjects.isEmpty) {
      return 'Tu as parcouru « $domain » avec aisance. Voici comment '
          'transformer cet acquis en expertise durable.';
    }
    return 'Tu as bien avancé sur « $domain ». Certains sujets t\'ont '
        'demandé plus d\'effort — la suite est pensée pour les consolider.';
  }
}

// ---------------------------------------------------------------------------
// Sub-theme adjacency: which sub-themes naturally follow a struggled subject.
// Keyed loosely by keywords found in chapter subjects.
// ---------------------------------------------------------------------------

/// Maps a chapter "subject" keyword to suggested sub-theme ids within the
/// SAME domain (deepening) — chosen because the user lingered on that topic.
const Map<String, List<String>> _subjectToSubThemes = {
  // generic chapter archetypes (standard 12-chapter program)
  'fondations': ['biais', 'identite', 'gestion-temps'],
  'point de départ': ['estime', 'image-corpo'],
  'rituel': ['organisation', 'rituel-soir', 'focus'],
  'victoires': ['motivation', 'estime'],
  'obstacles': ['resilience', 'procrastination', 'stress-burnout'],
  'pratique': ['focus', 'energie'],
  'régularité': ['organisation', 'gestion-temps', 'rythme'],
  'progrès': ['motivation', 'perf-sommeil'],
  'exigence': ['leadership', 'confiance-pro'],
  'stratégie': ['priorisation', 'projet'],
  'durablement': ['identite', 'independance'],
  'autonome': ['leadership', 'independance', 'imposteur'],
};

/// Picks the best-matching sub-themes for a list of struggled subjects within
/// the same domain. Returns sub-theme ids that actually exist in the domain.
List<String> _deepeningSubThemes(
  DomainItem domain,
  List<String> strugglingSubjects,
) {
  final available = domain.subThemes.map((s) => s.id).toSet();
  final picked = <String>[];

  for (final subject in strugglingSubjects) {
    final lower = subject.toLowerCase();
    for (final entry in _subjectToSubThemes.entries) {
      if (lower.contains(entry.key)) {
        for (final id in entry.value) {
          if (available.contains(id) && !picked.contains(id)) {
            picked.add(id);
          }
        }
      }
    }
  }
  return picked;
}

/// Adjacent domains to explore once a domain is (almost) finished.
const Map<String, List<String>> _adjacentDomains = {
  'psychologie': ['confiance', 'relations', 'anxiete'],
  'anxiete': ['psychologie', 'sommeil', 'bien-etre'],
  'productivite': ['confiance', 'habitudes', 'apprentissage'],
  'sport': ['nutrition', 'sommeil', 'bien-etre'],
  'nutrition': ['sport', 'sommeil', 'bien-etre'],
  'relations': ['psychologie', 'confiance', 'anxiete'],
  'sommeil': ['anxiete', 'bien-etre', 'habitudes'],
  'confiance': ['psychologie', 'relations', 'business'],
  'bien-etre': ['anxiete', 'spiritualite', 'sommeil'],
  'apprentissage': ['productivite', 'business', 'creativite-arts'],
  'business': ['finance', 'confiance', 'productivite'],
  'finance': ['business', 'habitudes', 'productivite'],
  'spiritualite': ['bien-etre', 'psychologie', 'habitudes'],
  'creativite-arts': ['apprentissage', 'bien-etre', 'productivite'],
  'habitudes': ['productivite', 'bien-etre', 'finance'],
};

// ---------------------------------------------------------------------------
// Public: build the completion report + recommendations
// ---------------------------------------------------------------------------

CompletionReport buildCompletionReport(
  Program program,
  ProgressState progress,
) {
  final modulesDone = progress.completedModules.length;
  final modulesTotal = program.modules.length;
  final ratio = modulesTotal == 0 ? 0.0 : modulesDone / modulesTotal;

  // Average quiz ratio across recorded module quizzes.
  final quizRatios = <double>[];
  for (final m in program.modules) {
    final score = progress.moduleScores[m.id];
    if (score != null && m.quiz.isNotEmpty) {
      quizRatios.add(score / m.quiz.length);
    }
  }
  final avgQuiz = quizRatios.isEmpty
      ? 0.0
      : quizRatios.reduce((a, b) => a + b) / quizRatios.length;

  // Struggling subjects = struggled module ids → readable subjects.
  final struggledIds = strugglingModuleIds(program, progress).toSet();
  final strugglingSubjects = <String>[];
  final strongSubjects = <String>[];
  for (final m in program.modules) {
    if (!progress.completedModules.contains(m.id)) continue;
    final subject = subjectOf(m.title);
    if (struggledIds.contains(m.id)) {
      strugglingSubjects.add(subject);
    } else {
      final score = progress.moduleScores[m.id];
      if (score != null && m.quiz.isNotEmpty && score / m.quiz.length >= 0.8) {
        strongSubjects.add(subject);
      }
    }
  }

  // Total minutes (seconds → minutes), summed over recorded times.
  final totalSeconds = progress.moduleTimes.values.fold(0, (s, v) => s + v);
  final totalMinutes = (totalSeconds / 60).ceil();

  final recommendations = _buildRecommendations(
    program,
    strugglingSubjects,
    avgQuiz,
  );

  return CompletionReport(
    domain: program.domain,
    modulesDone: modulesDone,
    modulesTotal: modulesTotal,
    completionRatio: ratio,
    avgQuizRatio: avgQuiz,
    strugglingSubjects: strugglingSubjects,
    strongSubjects: strongSubjects,
    totalMinutes: totalMinutes,
    recommendations: recommendations,
  );
}

List<Recommendation> _buildRecommendations(
  Program program,
  List<String> strugglingSubjects,
  double avgQuiz,
) {
  final recs = <Recommendation>[];

  // Resolve current domain by matching the program domain label.
  final target = program.domain.trim().toLowerCase();
  DomainItem? currentDomain;
  for (final d in kDomains) {
    if (d.label.toLowerCase() == target) {
      currentDomain = d;
      break;
    }
  }

  // 1) Deepening recommendations — sub-themes tied to struggled subjects.
  if (currentDomain != null) {
    final deepen = _deepeningSubThemes(currentDomain, strugglingSubjects);
    for (final id in deepen.take(2)) {
      final st = currentDomain.subThemes.firstWhere((s) => s.id == id);
      final subject = strugglingSubjects.isNotEmpty
          ? strugglingSubjects.first
          : 'ce thème';
      recs.add(
        Recommendation(
          domainId: currentDomain.id,
          domainLabel: currentDomain.label,
          subThemeId: st.id,
          subThemeLabel: st.label,
          emoji: st.emoji,
          reason:
              'Tu as pris ton temps sur « $subject » — ce focus le consolide en profondeur.',
          isSameDomain: true,
        ),
      );
    }

    // 2) If high mastery → suggest Expert mode of the same domain.
    if (avgQuiz >= 0.75) {
      final st = currentDomain.subThemes.first;
      recs.add(
        Recommendation(
          domainId: currentDomain.id,
          domainLabel: currentDomain.label,
          subThemeId: st.id,
          subThemeLabel: st.label,
          emoji: '🎓',
          reason:
              'Ta maîtrise est solide. Le mode Expert pousse « ${currentDomain.label} » beaucoup plus loin.',
          isSameDomain: true,
          isExpert: true,
        ),
      );
    }

    // 3) Fill with an unused sub-theme of the same domain if room remains.
    if (recs.length < 2) {
      for (final st in currentDomain.subThemes) {
        if (recs.any((r) => r.subThemeId == st.id && !r.isExpert)) continue;
        recs.add(
          Recommendation(
            domainId: currentDomain.id,
            domainLabel: currentDomain.label,
            subThemeId: st.id,
            subThemeLabel: st.label,
            emoji: st.emoji,
            reason: 'Un angle complémentaire pour enrichir tes acquis.',
            isSameDomain: true,
          ),
        );
        if (recs.length >= 2) break;
      }
    }
  }

  // 4) Exploration — one adjacent domain.
  final adj = _adjacentDomains[currentDomain?.id] ?? const [];
  for (final domId in adj) {
    final dom = kDomains.where((d) => d.id == domId);
    if (dom.isEmpty) continue;
    final d = dom.first;
    final st = d.subThemes.first;
    recs.add(
      Recommendation(
        domainId: d.id,
        domainLabel: d.label,
        subThemeId: st.id,
        subThemeLabel: st.label,
        emoji: d.subThemes.first.emoji,
        reason:
            '« ${d.label} » se marie naturellement avec ce que tu viens d\'apprendre.',
        isSameDomain: false,
      ),
    );
    break; // only one exploration suggestion
  }

  return recs;
}
