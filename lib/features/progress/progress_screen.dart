import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/adaptive/adaptive.dart';
import '../../state/app_providers.dart';
import '../../ui/animations/fade_slide.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';

/// Visualises completion, quiz score and earned badges.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(programControllerProvider);
    final progress = ref.watch(progressControllerProvider);
    final totalModules = program?.modules.length ?? 0;
    final done = progress.completedModules.length;
    final moduleRatio = totalModules == 0 ? 0.0 : done / totalModules;
    final quizRatio = progress.quizTotal == 0
        ? 0.0
        : progress.quizScore / progress.quizTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progression'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            FadeSlideIn(
              child: Row(
                children: [
                  Expanded(
                    child: _StatCircle(
                      label: 'Modules',
                      value: moduleRatio,
                      caption: '$done/$totalModules',
                      color: AppColors.brandStart,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _StatCircle(
                      label: 'Quiz',
                      value: quizRatio,
                      caption:
                          '${progress.quizScore}/${progress.quizTotal == 0 ? '–' : progress.quizTotal}',
                      color: AppColors.sky,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Modules complétés',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (program != null)
              ...List.generate(program.modules.length, (i) {
                final m = program.modules[i];
                final c = progress.completedModules.contains(m.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(
                        c
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: c ? AppColors.success : AppColors.inkSoft,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          m.title,
                          style: TextStyle(
                            color: c ? AppColors.ink : AppColors.inkSoft,
                            fontWeight:
                                c ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            if (program != null && progress.moduleTimes.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Temps par chapitre',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Repère où tu as ralenti — c\'est là que ton parcours '
                  's\'adapte.',
                  style: TextStyle(fontSize: 13, color: AppColors.inkSoft)),
              const SizedBox(height: 12),
              ...() {
                final struggling =
                    strugglingModuleIds(program, progress).toSet();
                final maxT = progress.moduleTimes.values.fold<int>(1, max);
                return [
                  for (final m in program.modules)
                    if ((progress.moduleTimes[m.id] ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TimeRow(
                          subject: subjectOf(m.title),
                          seconds: progress.moduleTimes[m.id]!,
                          fraction: progress.moduleTimes[m.id]! / maxT,
                          slow: struggling.contains(m.id),
                        ),
                      ),
                ];
              }(),
            ],
            const SizedBox(height: 16),
            const Text('Badges',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (progress.badges.isEmpty)
              Text('Aucun badge pour l\'instant. Continue ! 💪',
                  style: TextStyle(color: AppColors.inkSoft))
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: progress.badges
                    .map((b) => BadgeChip(label: b))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

String _fmtTime(int s) {
  if (s < 60) return '$s s';
  final m = s ~/ 60;
  final r = s % 60;
  return r == 0 ? '$m min' : '$m min $r s';
}

class _TimeRow extends StatelessWidget {
  final String subject;
  final int seconds;
  final double fraction; // 0..1 relative to the slowest chapter
  final bool slow;

  const _TimeRow({
    required this.subject,
    required this.seconds,
    required this.fraction,
    required this.slow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  if (slow) ...[
                    const SizedBox(width: 8),
                    BadgeChip(
                      label: 'Ralenti',
                      icon: Icons.hourglass_bottom_rounded,
                      color: AppColors.peach,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: fraction.clamp(0.04, 1),
                  minHeight: 8,
                  backgroundColor: AppColors.line,
                  valueColor: AlwaysStoppedAnimation(
                      slow ? AppColors.peach : AppColors.brandStart),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(_fmtTime(seconds),
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}

class _StatCircle extends StatelessWidget {
  final String label;
  final double value;
  final String caption;
  final Color color;

  const _StatCircle({
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: value.clamp(0, 1)),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      value: v,
                      strokeWidth: 9,
                      backgroundColor: AppColors.line,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                Text(caption,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
