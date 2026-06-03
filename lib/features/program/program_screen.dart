import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/adaptive/adaptive.dart';
import '../../core/adaptive/recommendation_engine.dart';
import '../../core/models/content_models.dart';
import '../../state/app_providers.dart';
import '../../ui/animations/fade_slide.dart';
import '../../ui/animations/reveal_on_scroll.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';

/// Program overview: progress, module list and shortcuts to quiz / progress /
/// reminders / final report. Modules open via tap OR a swipe-up gesture.
class ProgramScreen extends ConsumerWidget {
  const ProgramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(programControllerProvider);
    final progress = ref.watch(progressControllerProvider);

    if (program == null) {
      return const Scaffold(
        body: Center(child: Text('Aucun programme. Reviens à l\'accueil.')),
      );
    }

    final completed = progress.completedModules.length;
    final ratio = program.modules.isEmpty
        ? 0.0
        : completed / program.modules.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home_rounded),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Mon programme'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            onPressed: () => context.push('/progress'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            FadeSlideIn(
              child: SoftCard(
                gradient: AppColors.brandGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      program.subtitle,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: GradientProgressBar(value: ratio)),
                        const SizedBox(width: 12),
                        Text(
                          '$completed/${program.modules.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_adaptiveCount(program, progress) > 0) ...[
              const SizedBox(height: 14),
              FadeSlideIn(
                child: SoftCard(
                  color: AppColors.lavender.withValues(alpha: 0.20),
                  child: Row(
                    children: [
                      Icon(Icons.tune_rounded, color: AppColors.ink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Parcours adapté à toi : les prochains chapitres '
                          'reviennent sur ${_adaptiveCount(program, progress)} '
                          'sujet(s) où tu as pris ton temps.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.ink,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Near-completion (≥ 80%) → surface the "what's next" report.
            if (ratio >= 0.8) ...[
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 40),
                child: _NearCompletionCard(
                  report: buildCompletionReport(program, progress),
                  fullyDone: completed >= program.modules.length,
                ),
              ),
            ],
            if (completed < program.modules.length) ...[
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: SoftCard(
                  color: AppColors.peach.withValues(alpha: 0.18),
                  child: Row(
                    children: [
                      Icon(Icons.alarm_on_rounded, color: AppColors.ink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Rappel automatique activé : on te relancera chaque '
                          'jour tant que ton programme n\'est pas terminé.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.ink,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: [
                  const Text(
                    '3 niveaux d\'apprentissage',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    'facile → avancé',
                    style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
            ..._buildParcours(context, ref, program, progress),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: Icons.quiz_rounded,
                    label: 'Quiz',
                    color: AppColors.sky,
                    onTap: () => context.push('/quiz'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.notifications_active_rounded,
                    label: 'Rappels',
                    color: AppColors.peach,
                    onTap: () => context.push('/reminders'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GradientButton(
              label: 'Bilan & plan personnalisé',
              icon: Icons.flag_rounded,
              onPressed: () => context.push('/final'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the parcours: chapters grouped by part, each part followed by its
  /// transversal quiz. Falls back to a flat chapter list if no parts exist.
  List<Widget> _buildParcours(
    BuildContext context,
    WidgetRef ref,
    Program program,
    ProgressState progress,
  ) {
    if (program.parts.isEmpty) {
      return List.generate(program.modules.length, (i) {
        final m = program.modules[i];
        return RevealOnScroll(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ModuleCard(
              index: i,
              module: m,
              done: progress.completedModules.contains(m.id),
              locked: false,
              onOpen: () => context.push('/module/$i'),
            ),
          ),
        );
      });
    }

    final widgets = <Widget>[];
    // A level is unlocked only when the previous level is fully completed.
    var previousComplete = true;
    for (var p = 0; p < program.parts.length; p++) {
      final part = program.parts[p];
      final partModulesDone = part.moduleIds
          .where(progress.completedModules.contains)
          .length;
      final allDone = partModulesDone == part.moduleIds.length;
      final locked = !previousComplete;

      widgets.add(_PartHeader(part: part, locked: locked, completed: allDone));
      for (final id in part.moduleIds) {
        final i = program.modules.indexWhere((m) => m.id == id);
        if (i < 0) continue;
        final m = program.modules[i];
        widgets.add(
          RevealOnScroll(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ModuleCard(
                index: i,
                module: m,
                done: progress.completedModules.contains(m.id),
                locked: locked,
                onOpen: locked
                    ? () => _lockedToast(context)
                    : () => context.push('/module/$i'),
              ),
            ),
          ),
        );
      }
      widgets.add(
        RevealOnScroll(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _PartQuizCard(
              score: progress.partScores[part.id],
              total: part.quiz.length,
              locked: locked,
              unlocked: allDone,
              partDone: partModulesDone,
              partTotal: part.moduleIds.length,
              onTap: locked
                  ? () => _lockedToast(context)
                  : () => context.push('/partquiz/$p'),
            ),
          ),
        ),
      );

      previousComplete = allDone;
    }
    return widgets;
  }

  /// How many earlier subjects will be reinforced in upcoming chapters.
  int _adaptiveCount(Program program, ProgressState progress) {
    final struggling = strugglingModuleIds(program, progress);
    // Only counts if there's at least one not-yet-finished chapter after them
    // to carry the reinforcement.
    final allDone = progress.completedModules.length >= program.modules.length;
    return allDone ? 0 : struggling.length;
  }

  void _lockedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '🔒 Termine le niveau précédent pour débloquer celui-ci.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Shown when the program is ≥ 80% complete: a celebratory header that links
/// to the full mini-report + recommendations on the final screen.
class _NearCompletionCard extends StatelessWidget {
  final CompletionReport report;
  final bool fullyDone;
  const _NearCompletionCard({required this.report, required this.fullyDone});

  @override
  Widget build(BuildContext context) {
    final remaining = report.modulesTotal - report.modulesDone;
    final topRec = report.recommendations.isNotEmpty
        ? report.recommendations.first
        : null;

    return SoftCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.brandStart, AppColors.brandEnd],
      ),
      onTap: () => context.push('/final'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                fullyDone ? '🎉' : '🏁',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  fullyDone
                      ? 'Programme terminé — voici la suite !'
                      : 'Tu y es presque ! Plus que $remaining chapitre(s)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            fullyDone
                ? 'Découvre ton mini-rapport et nos recommandations pour la suite de ton apprentissage.'
                : 'Termine ton programme pour débloquer ton mini-rapport complet et tes recommandations personnalisées.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (topRec != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(topRec.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suggestion : ${topRec.subThemeLabel}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          topRec.isSameDomain
                              ? 'Approfondir ${topRec.domainLabel}'
                              : 'Explorer ${topRec.domainLabel}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.80),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                fullyDone ? 'Voir mon rapport' : 'Voir mon bilan',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartHeader extends StatelessWidget {
  final ProgramPart part;
  final bool locked;
  final bool completed;
  const _PartHeader({
    required this.part,
    required this.locked,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final dim = locked ? 0.45 : 1.0;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Opacity(
        opacity: dim,
        child: Row(
          children: [
            Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          part.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _DifficultyDots(level: part.level),
                    ],
                  ),
                  Text(
                    part.subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
            if (locked)
              Icon(Icons.lock_rounded, color: AppColors.inkSoft, size: 20)
            else if (completed)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

/// Three dots showing the level's intensity (filled = current level).
class _DifficultyDots extends StatelessWidget {
  final int level;
  const _DifficultyDots({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final on = i < level;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: on ? AppColors.brandStart : AppColors.line,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

class _PartQuizCard extends StatelessWidget {
  final int? score;
  final int total;
  final bool locked;
  final bool unlocked;
  final int partDone;
  final int partTotal;
  final VoidCallback onTap;

  const _PartQuizCard({
    required this.score,
    required this.total,
    required this.locked,
    required this.unlocked,
    required this.partDone,
    required this.partTotal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final taken = score != null;
    final subtitle = locked
        ? 'Verrouillé • finis le niveau précédent'
        : taken
        ? 'Score : $score/$total'
        : unlocked
        ? 'Teste tes connaissances sur ce niveau'
        : 'Dispo maintenant • chapitres $partDone/$partTotal faits';
    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: SoftCard(
        color: AppColors.sky.withValues(alpha: 0.16),
        onTap: onTap,
        child: Row(
          children: [
            TintedIcon(
              icon: locked
                  ? Icons.lock_rounded
                  : taken
                  ? Icons.workspace_premium_rounded
                  : Icons.fact_check_rounded,
              color: AppColors.sky,
              size: 46,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quiz transversal du niveau',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
            Icon(
              locked ? Icons.lock_rounded : Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.inkSoft,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final int index;
  final Module module;
  final bool done;
  final bool locked;
  final VoidCallback onOpen;

  const _ModuleCard({
    required this.index,
    required this.module,
    required this.done,
    required this.locked,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    // Swipe-up to open: fling upward triggers navigation (only when unlocked).
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (!locked && (details.primaryVelocity ?? 0) < -250) onOpen();
      },
      child: Opacity(
        opacity: locked ? 0.55 : 1,
        child: SoftCard(
          onTap: onOpen,
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: (done || locked) ? null : AppColors.brandGradient,
                  color: done
                      ? AppColors.success
                      : locked
                      ? AppColors.line
                      : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: done
                    ? const Icon(Icons.check_rounded, color: Colors.white)
                    : locked
                    ? Icon(
                        Icons.lock_rounded,
                        color: AppColors.inkSoft,
                        size: 20,
                      )
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      module.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              Icon(
                locked ? Icons.lock_rounded : Icons.keyboard_arrow_up_rounded,
                color: AppColors.inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: color.withValues(alpha: 0.16),
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          TintedIcon(icon: icon, color: color, size: 46),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
